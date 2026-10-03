const navLinks = document.querySelectorAll('.side-bar .nav-link');
const pages = document.querySelectorAll('.page');

function checkStudentAuth() {
  if (sessionStorage.getItem('student_auth') !== '1') window.location.replace('../s_login.html');
}
checkStudentAuth();

// Re-run on back/forward restore (bfcache) so Alt+Arrow can't reopen dashboard
window.addEventListener('pageshow', (e) => {
  if (e.persisted) checkStudentAuth();
});

function logout() {
  sessionStorage.removeItem('student_auth');
  sessionStorage.removeItem('student_roll');
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

window.addEventListener('hashchange', render);
render();
