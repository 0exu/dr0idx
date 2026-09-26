//Creating elements for handling...
const roleSelector = document.getElementById('roleSelector')
const submitBtn = document.getElementById('submitBtn')

// This is the main event listner 
submitBtn.addEventListener('click', function() {
  const selectedRole = roleSelector.value;

  // Null value throw on him/her face...
  if (selectedRole == '') {
    alert('Please select a role to continue...')
    return;
  }
  // main selector...
  if (selectedRole === 'student') {
    window.location.href = '../student/index.html';
  } else if (selectedRole === 'teacher') {
    window.location.href = '../teacher/index.html';
  }
});

// Beauty of javascript. Hit enter after select you will land to that page. 
roleSelector.addEventListener('keypress', function(event){
  if(event.key === 'Enter') {
    submitBtn.click();
  }
})
