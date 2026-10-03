const API = 'http://localhost:8080';

const navLinks = document.querySelectorAll('.side-bar .nav-link');
const pages = document.querySelectorAll('.page');

function checkTeacherAuth() {
  if (sessionStorage.getItem('teacher_auth') !== '1' || !sessionStorage.getItem('teacher_session')) {
    window.location.replace('../t_login.html');
  }
}
checkTeacherAuth();

// Re-run on back/forward restore (bfcache) so Alt+Arrow can't reopen dashboard
window.addEventListener('pageshow', (e) => {
  if (e.persisted) checkTeacherAuth();
});

function logout() {
  const session = sessionStorage.getItem('teacher_session');
  if (session) {
    fetch(`${API}/logout`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ session_id: session }),
    }).catch(() => {});
  }
  sessionStorage.removeItem('teacher_auth');
  sessionStorage.removeItem('teacher_tid');
  sessionStorage.removeItem('teacher_session');
  window.location.replace('../t_login.html');
}

document.getElementById('logoutBtn')?.addEventListener('click', (e) => {
  e.preventDefault();
  logout();
});

const pageOrder = ['home', 'my-courses', 'academics', 'attendence', 'notices'];
let animating = false;

function render() {
  const id = location.hash.slice(1) || 'home';
  const page = document.getElementById(id);
  if (!page || !page.classList.contains('page')) return;

  loadPage(id);

  navLinks.forEach(l => {
    const on = l.dataset.page === id;
    l.classList.toggle('active', on);
    if (on) l.setAttribute('aria-current', 'page');
    else l.removeAttribute('aria-current');
  });

  const current = document.querySelector('.page.active');

  // first paint, or same section - no animation
  if (!current || current === page) {
    pages.forEach(p => {
      p.classList.remove('leaving', 'from-left');
      p.classList.toggle('active', p === page);
    });
    return;
  }

  // mid-animation clicks are ignored so sections can't get stuck
  if (animating) return;

  // forward = slide in from the right, backward = from the left
  const backward = pageOrder.indexOf(id) < pageOrder.indexOf(current.id);

  current.classList.add('leaving');
  current.classList.remove('active');
  page.classList.toggle('from-left', backward);
  page.classList.add('active');
  animating = true;

  setTimeout(() => {
    current.classList.remove('leaving');
    animating = false;
  }, 350);
}

navLinks.forEach(l => l.addEventListener('click', () => {
  location.hash = l.dataset.page;
}));

document.querySelectorAll('[data-goto]').forEach(tile => {
  const go = () => { location.hash = tile.dataset.goto; };
  tile.addEventListener('click', go);
  tile.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); go(); }
  });
});

const ROUTES = {
  'my-courses': { path: '/api/teacher/courses', target: 'courses-list', render: renderCourses },
  'academics': { path: '/api/teacher/academics', target: 'academics-list', render: renderAcademics },
  'attendence': { path: '/api/teacher/attendance', target: 'attendance-list', render: renderAttendance },
  'notices': { path: '/api/teacher/notices', target: 'notices-list', method: 'GET', render: renderNotices },
};

const loaded = new Set();

async function api(path, method = 'POST', extra = {}) {
  const session = sessionStorage.getItem('teacher_session');
  const headers = { 'X-Session-Id': session };
  const options = { method, headers };

  // a GET request cannot carry a body, so the session rides in the header
  if (method !== 'GET') {
    headers['Content-Type'] = 'application/json';
    options.body = JSON.stringify({ session_id: session, ...extra });
  }

  const response = await fetch(`${API}${path}`, options);

  if (response.status === 401) {
    sessionStorage.clear();
    window.location.replace('../t_login.html');
    return null;
  }

  const data = await response.json();
  if (!response.ok) throw new Error(data.message || 'request failed');
  return data;
}

async function loadPage(id) {
  if (id === 'home') return loadHome();
  const route = ROUTES[id];
  if (!route) return;

  const box = document.getElementById(route.target);
  if (loaded.has(id)) return;

  try {
    box.textContent = 'Loading...';
    const rows = await api(route.path, route.method || 'POST');
    loaded.add(id);
    route.render(box, rows);
  } catch (error) {
    box.textContent = '';
    box.append(el('p', 'empty', `Could not load: ${error.message}`));
  }
}

async function loadHome() {
  if (loaded.has('home')) return;
  try {
    const stats = await api('/api/teacher/dashboard');
    loaded.add('home');
    text('tile-courses', stats.sections_teaching);
    text('tile-students', stats.total_students);
    text('tile-materials', stats.materials_uploaded);
    text('tile-notices', stats.notices_posted);
    text('tile-who', `${stats.NAME ?? ''} (tid ${stats.TID ?? ''}) - ${stats.DEPT ?? ''}`);
  } catch (error) {
    /* tiles keep their placeholder dashes */
  }
}

function el(tag, className, textContent) {
  const node = document.createElement(tag);
  if (className) node.className = className;
  if (textContent != null) node.textContent = textContent;
  return node;
}

function text(id, value) {
  const node = document.getElementById(id);
  if (node) node.textContent = value;
}

function fill(box, rows, build, emptyMessage) {
  box.textContent = '';
  if (!rows.length) {
    box.append(el('p', 'empty', emptyMessage));
    return;
  }
  rows.forEach(row => box.append(build(row)));
}

function renderCourses(box, rows) {
  fill(box, rows, (row) => {
    const card = el('div', 'data-row');
    const main = el('div', 'data-main');
    main.append(el('strong', 'data-title', `${row.COURSE_ID} - ${row.COURSE_NAME}`));
    main.append(el('span', 'data-sub', `${row.CREDITS ?? 0} credits`));
    card.append(main, el('span', 'data-meta', `${row.enrolled} enrolled`));
    return card;
  }, 'No courses assigned to you yet.');
}

function renderAcademics(box, rows) {
  fill(box, rows, (row) => {
    const card = el('div', 'data-row');
    const main = el('div', 'data-main');
    main.append(el('strong', 'data-title', `${row.ROLL} - ${row.NAME}`));
    main.append(el('span', 'data-sub', `${row.COURSE_NAME} / ${row.TITLE} - ${row.SEM_MARKS} of ${row.MAX_MARKS}`));
    card.append(main, el('span', 'data-meta pct', `${row.percentage}%`));
    return card;
  }, 'No marks recorded yet.');
}

function renderAttendance(box, rows) {
  fill(box, rows, (row) => {
    const card = el('div', 'data-row');
    const main = el('div', 'data-main');
    main.append(el('strong', 'data-title', row.COURSE_NAME));
    main.append(el('span', 'data-sub', `class on ${row.CLASS_DATE}`));
    card.append(main, el('span', 'data-meta', `${row.present_count} present of ${row.total_count}`));
    return card;
  }, 'No attendance marked yet.');
}

function renderNotices(box, rows) {
  fill(box, rows, (row) => {
    const card = el('div', `data-row notice ${row.PRIORITY}`);
    const main = el('div', 'data-main');
    main.append(el('strong', 'data-title', row.TITLE));
    main.append(el('p', 'data-body', row.CONTENT));
    main.append(el('span', 'data-sub', `for ${row.AUDIENCE} - ${row.CREATED_AT}`));
    card.append(main, el('span', 'data-meta badge', row.PRIORITY));
    return card;
  }, 'You have not posted any notices yet.');
}

document.getElementById('noticeForm').addEventListener('submit', async (e) => {
  e.preventDefault();
  const msg = document.getElementById('noticeMsg');
  const button = e.target.querySelector('button');
  button.disabled = true;
  msg.textContent = 'Posting...';
  msg.className = 'notice-msg';

  try {
    const data = await api('/api/teacher/notices', 'POST', {
      title: document.getElementById('noticeTitle').value,
      content: document.getElementById('noticeContent').value,
      priority: document.getElementById('noticePriority').value,
      audience: document.getElementById('noticeAudience').value,
    });
    msg.textContent = data.message || 'Posted';
    msg.className = 'notice-msg ok';
    e.target.reset();
    loaded.delete('notices');
    await loadPage('notices');
    loaded.delete('home');
    loadHome();
  } catch (error) {
    msg.textContent = error.message;
    msg.className = 'notice-msg bad';
  } finally {
    button.disabled = false;
  }
});

// started last: render() reaches into the data layer above
window.addEventListener('hashchange', render);
render();
