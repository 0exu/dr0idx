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

function render() {
  const id = location.hash.slice(1) || 'home';
  const page = document.getElementById(id);
  if(!page || !page.classList.contains('page')) return;

  pages.forEach(p => p.classList.toggle('active', p === page));
  navLinks.forEach(l => {
    const on = l.dataset.page === id;
    l.classList.toggle('active', on);
    if(on) l.setAttribute('aria-current', 'page');
    else l.removeAttribute('aria-current');
  });
}

navLinks.forEach(l => l.addEventListener('click', () => {
  location.hash = l.dataset.page;
}));

window.addEventListener('hashchange', render);
render();
