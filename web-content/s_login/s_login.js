document.getElementById('togglePw').addEventListener('click', (e) => {
  const p = document.getElementById('password');
  const btn = e.currentTarget;
  const show = p.type === 'password';
  p.type = show ? 'text' : 'password';
  btn.classList.toggle('show', show);
  btn.setAttribute('aria-label', show ? 'Hide password' : 'Show password');
});

document.getElementById('loginForm').addEventListener('submit', async (e) => {
  e.preventDefault();
  const roll = document.getElementById('roll').value.trim();
  const password = document.getElementById('password').value;
  const messageDiv = document.getElementById('message');

  // Clear the previous message for new session
  messageDiv.className = 'message';
  messageDiv.textContent = '';

  try {
    // Main send function to local server running on mysystem
    const response = await fetch('http://localhost:8080/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        roll: roll,
        password: password,
      }),
    });
    const data = await response.json();
    if (response.ok) {
      sessionStorage.setItem('student_auth', '1');
      sessionStorage.setItem('student_roll', data.roll);
      messageDiv.className = 'message success';
      messageDiv.textContent = 'Welcome ' + data.name;
      document.getElementById('loginForm').reset();
      setTimeout(() => {
        window.location.href = './student/index.html';
      }, 10000);
    } else {
      messageDiv.className = 'message error';
      messageDiv.textContent = 'Incorrect Login ' + data.message;
    }
  } catch (error) {
    messageDiv.className = 'message error';
    messageDiv.textContent = '[x] Unable to connect server';
    console.error('Error:', error);
  }
});
