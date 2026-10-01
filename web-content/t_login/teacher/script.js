function checkTeacherAuth() {
  if (sessionStorage.getItem('teacher_auth') !== '1') window.location.replace('../t_login.html');
}
checkTeacherAuth();

// Re-run on back/forward restore (bfcache) so Alt+Arrow can't reopen dashboard
window.addEventListener('pageshow', (e) => {
  if (e.persisted) checkTeacherAuth();
});

function logout() {
  sessionStorage.removeItem('teacher_auth');
  sessionStorage.removeItem('teacher_tid');
  window.location.replace('../t_login.html');
}

document.getElementById('logoutBtn')?.addEventListener('click', (e) => {
  e.preventDefault();
  logout();
});
