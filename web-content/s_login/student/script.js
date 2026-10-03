const navLinks = document.querySelectorAll('.side-bar .nav-link');
const pages = document.querySelectorAll('.page');

const API = 'http://localhost:8080';

function checkStudentAuth() {
  if (sessionStorage.getItem('student_auth') !== '1' || !sessionStorage.getItem('student_session')) {
    window.location.replace('../s_login.html');
  }
}
checkStudentAuth();

// Re-run on back/forward restore (bfcache) so Alt+Arrow can't reopen dashboard
window.addEventListener('pageshow', (e) => {
  if (e.persisted) checkStudentAuth();
});

function logout() {
  const session = sessionStorage.getItem('student_session');
  if (session) {
    fetch(`${API}/logout`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ session_id: session }),
    }).catch(() => {});
  }
  sessionStorage.removeItem('student_auth');
  sessionStorage.removeItem('student_roll');
  sessionStorage.removeItem('student_session');
  window.location.replace('../s_login.html');
}

document.getElementById('logoutBtn')?.addEventListener('click', (e) => {
  e.preventDefault();
  logout();
});

const pageOrder = ['home', 'study-materials', 'academics', 'attendence', 'notices'];
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

  if (!current || current === page) {
    pages.forEach(p => {
      p.classList.remove('leaving', 'from-left');
      p.classList.toggle('active', p === page);
    });
    return;
  }

  if (animating) return;

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
  'study-materials': { path: '/api/student/materials', target: 'materials-list', render: renderMaterials },
  'academics': { path: '/api/student/academics', target: 'academics-list', render: renderAcademics },
  'attendence': { path: '/api/student/attendance', target: 'attendance-list', render: renderAttendance },
  'notices': { path: '/api/student/notices', target: 'notices-list', render: renderNotices },
};

const loaded = new Set();

async function fetchSection(path, extra = {}) {
  const response = await fetch(`${API}${path}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ session_id: sessionStorage.getItem('student_session'), ...extra }),
  });

  if (response.status === 401) {
    sessionStorage.clear();
    window.location.replace('../s_login.html');
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
  if (loaded.has(id)) return; // already fetched once per visit

  try {
    box.textContent = 'Loading...';
    const rows = await fetchSection(route.path);
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
    const stats = await fetchSection('/api/student/dashboard');
    loaded.add('home');

    text('tile-materials', stats.new_materials);
    text('tile-notices', stats.recent_notices);
    text('tile-academics', stats.avg_percentage == null ? 'n/a' : `${stats.avg_percentage}%`);

    const attended = stats.present_last_30 ?? 0;
    const total = stats.total_last_30 ?? 0;
    const pct = total ? Math.round((attended / total) * 100) : null;
    text('tile-attendance', pct == null ? 'n/a' : `${pct}%`);
    text('tile-courses', `${stats.enrolled_courses ?? 0} courses enrolled  -  ${stats.NAME ?? ''} (roll ${stats.ROLL ?? ''})`);
  } catch (error) {
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

function humanSize(bytes) {
  if (!bytes) return '';
  const kb = bytes / 1024;
  return kb >= 1024 ? `${(kb / 1024).toFixed(1)} MB` : `${kb.toFixed(0)} KB`;
}

// the three academic divisions, in the order they should appear
const DIVISIONS = ['CLASS TEST 1', 'CLASS TEST 2', 'FINAL SEMESTER'];

function groupBy(rows, key) {
  const map = new Map();
  rows.forEach(row => {
    const k = row[key];
    if (!map.has(k)) map.set(k, []);
    map.get(k).push(row);
  });
  return map;
}

// unknown titles sort after the known ones instead of disappearing
function divisionRank(title) {
  const i = DIVISIONS.indexOf(String(title).toUpperCase());
  return i === -1 ? DIVISIONS.length : i;
}

function division(title, subtitle, cards) {
  const box = el('div', 'division');
  const head = el('div', 'division-head');
  head.append(el('h3', 'division-title', title), el('span', 'division-sub', subtitle));
  const body = el('div', 'division-body');
  cards.forEach(c => body.append(c));
  box.append(head, body);
  return box;
}

function formatDate(value) {
  if (!value) return '';
  const d = new Date(value);
  if (Number.isNaN(d.getTime())) return String(value);
  return d.toLocaleDateString(undefined, { day: '2-digit', month: 'short', year: 'numeric' });
}

function renderMaterials(box, rows) {
  box.textContent = '';
  if (!rows.length) {
    box.append(el('p', 'empty', 'No study materials for your courses yet.'));
    return;
  }

  // one block per course, so material is grouped the way it is taught
  groupBy(rows, 'COURSE_NAME').forEach((items, course) => {
    const cards = items.map(row => {
      const card = el('div', 'data-row');
      const main = el('div', 'data-main');
      const label = String(row.TITLE || '').startsWith(`${course} - `)
        ? row.TITLE.slice(course.length + 3)
        : row.TITLE;
      main.append(el('strong', 'data-title', label));
      main.append(el('span', 'data-sub', `${(row.FILE_TYPE || '').toUpperCase()} ${humanSize(row.FILE_SIZE)}`));
      card.append(main, el('span', 'data-meta', formatDate(row.UPLOAD_DATE)));
      return card;
    });
    box.append(division(course, `${items.length} file${items.length > 1 ? 's' : ''}`, cards));
  });
}

function renderAcademics(box, rows) {
  box.textContent = '';
  if (!rows.length) {
    box.append(el('p', 'empty', 'No results published yet.'));
    return;
  }

  // one block per division, each listing what the student scored in every course
  const groups = groupBy(rows, 'TITLE');
  [...groups.keys()]
    .sort((a, b) => divisionRank(a) - divisionRank(b) || String(a).localeCompare(String(b)))
    .forEach(title => {
      const items = groups.get(title);
      const cards = items.map(row => {
        const card = el('div', 'data-row');
        const main = el('div', 'data-main');
        main.append(el('strong', 'data-title', row.COURSE_NAME));
        main.append(el('span', 'data-sub', `scored ${row.SEM_MARKS} / ${row.MAX_MARKS}`));
        card.append(main, el('span', 'data-meta pct', `${row.percentage}%`));
        return card;
      });
      box.append(division(title, `out of ${items[0].MAX_MARKS}`, cards));
    });
}



function renderAttendance(box, rows) {
  fill(box, rows, (row) => {
    const card = el('div', 'data-row');
    const main = el('div', 'data-main');
    main.append(el('strong', 'data-title', row.COURSE_NAME));
    const parts = [`${row.attended} of ${row.classes_held} classes attended`];
    if (row.present_days != null) {
      parts.push(`${row.present_days} present, ${row.late_days} late, ${row.absent_days} absent`);
    }
    main.append(el('span', 'data-sub', parts.join(' - ')));
    card.append(main, el('span', 'data-meta pct', `${row.percentage}%`));
    return card;
  }, 'No attendance recorded yet.');
}

function renderNotices(box, rows) {
  fill(box, rows, (row) => {
    const card = el('div', `data-row notice ${row.PRIORITY}`);
    const main = el('div', 'data-main');
    main.append(el('strong', 'data-title', row.TITLE));
    main.append(el('p', 'data-body', row.CONTENT));
    main.append(el('span', 'data-sub', `${row.posted_by ?? 'staff'} - ${row.CREATED_AT}`));
    card.append(main, el('span', 'data-meta badge', row.PRIORITY));
    return card;
  }, 'No notices right now.');
}

// started last: render() reaches into the data layer above
window.addEventListener('hashchange', render);
render();
