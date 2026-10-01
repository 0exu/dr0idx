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
