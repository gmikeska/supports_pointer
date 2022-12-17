u = User.create(email:"dude@dude.com", handle:"dude", password:"temp123")
BlogPost.create(name:"Test", body:"This is a test post", author:u)
