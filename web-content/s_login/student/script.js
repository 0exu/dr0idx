if (sessionStorage.getItem('student_auth') !== '1') window.location.replace('../s_login.html');

function logout() {
  sessionStorage.clear();
  window.location.replace('../s_login.html');
}
