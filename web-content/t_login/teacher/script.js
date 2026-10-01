if (sessionStorage.getItem('teacher_auth') !== '1') window.location.replace('../t_login.html');

function logout() {
  sessionStorage.clear();
  window.location.replace('../t_login.html');
}
