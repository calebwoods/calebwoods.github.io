---
layout: post
title:  "OWASP Password Hashing in Ruby"
date:   2014-08-25 17:15:00
---

This week I've been working on extracting a Ruby service for authentication out of a Java application.  This particular application was using a version of the [OWASP Hashing example for Java](https://www.owasp.org/index.php/Hashing_Java).

### What make a secure password

The Java code I was replacing with this service linked to the [Open Web Application Security Project](https://www.owasp.org/index.php/Main_Page), a non-profit promoting best practices for security in web applications. OWASP defines a secure password has three important qualities.

1. Using a cryptographic hashing fuction
2. Salted
3. Hardened

### Hashing function

[OWASP](https://www.owasp.org/index.php/Hashing_Java) defines it as: "A Hash function creates a fixed length small fingerprint (or message digest) from an unlimited input string." As web developer most of us our familar with MD5 hashing functions.  

By using a one way hashing function a first layer of security is added as actual passwords are not stored in the datastore.

### Salted

A drawback to hashed passwords is that a hash of the same plain text password will also be the identical hashed password.  Additionally pre computed hashes can be used by an attacker find matches.

A salt is a random string of a fixed length which is added to the plain text password before it is hash.  This results in a unique hash for each password in a database.  Salts are usually stored in plain text along with the hash, to be used for checking matches.

### Hardened

The third technique is to harden the password by hashing the hash.  This process should be repeated a minimum of 1000 times according to the [RSA PKCS5 standard](http://tools.ietf.org/html/rfc2898#section-4.2).

```
hash(hash(hash(hash(hash(password + salt)))))
```

### Ruby example

The [OWASP website](https://www.owasp.org/index.php/Hashing_Java) gives a full example for Java. Below is an example of what the same hashing function looks like in Ruby.

```ruby
def compute_hash(password, salt)
  digestor = Digest::SHA1.new
  input = digestor.digest(salt + password)

  1000.times.inject(input) do |reply|
    digestor.digest(reply)
  end
end
```

It's good to note that the `SHA1` algorithm can switch for a more secure one such as `SHA256` or `SHA512` by requiring `'digest/sha2'`.

### Rails

Armed with the knowledge let's look at how the Rails framework helps of solve this problem.  As Rails 3.1 [has_secure_password](https://github.com/rails/rails/blob/master/activemodel/lib/active_model/secure_password.rb) provides simple interface to using [bcrypt](https://github.com/codahale/bcrypt-ruby) for hashing passwords.  Bcrypt handles creating and comparing salted hashed password automatically.  

To handle hardening Bcrypt has a option called cost which will harden your password. By default the factor is 10 which works out to 1,024 iterations, 2^10.  Also the cost is encoded in the resulting hash so it can be increased overtime and existing passwords will continue to work.

```ruby
# bcrypt-ruby example
my_password = BCrypt::Password.create("my password")
  #=> "$2a$10$vI8aWBnW3fID.ZQ4/zo1G.q1lRps.9cGLcZEiGDMVr5yUP1KUOYTa"

my_password.version              #=> "2a"
my_password.cost                 #=> 10
my_password == "my password"     #=> true
my_password == "not my password" #=> false

```

### Conclusion

Because of the popularity of Rails's `has_secure_password` and [Devise](https://github.com/plataformatec/devise) over the last few years it pretty safe to say almost all Rails app built in the last 3 years are using bcrypt password.  However, it is still good to the principles when evaluation authenticaiton systems or building password hashing in anther language.
