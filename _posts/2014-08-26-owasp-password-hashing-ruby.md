---
layout: post
title:  "OWASP Password Hashing in Ruby"
date:   2014-08-26 17:15:00
tags:
  - ruby
  - security
---

This week I've been working on extracting a Ruby service for authentication out of a legacy Java application.  This particular application was using a version of the [OWASP Hashing example for Java](https://www.owasp.org/index.php/Hashing_Java) which prompted me to do some research on secure passwords.

### What makes a secure password?

The Java code I was replacing linked to the [Open Web Application Security Project](https://www.owasp.org/index.php/Main_Page), a non-profit promoting best practices for security in web applications. OWASP defines a secure password as having three qualities:

1. Hashed
2. Salted
3. Hardened

### Hashed

[OWASP](https://www.owasp.org/index.php/Hashing_Java) explains: "A Hash function creates a fixed length small fingerprint (or message digest) from an unlimited input string." As web developers, most of us are familiar with MD5 or SHA hashing functions.  

Using a one-way hashing function increases security as the actual plain text passwords are not present in the datastore.

### Salted

A drawback to hashed passwords is that a hash of the two plain text passwords would be identical.  Because of this, if they had database access an attacker could use a database of precomputed hashes to look up common passwords.

A salt, however, is a random string of a fixed length that is added to the plain text password before it is hashed.  This results in a unique hash for each password in a database.  Salts are usually stored in plain text along with the hash and used for checking matches.

### Hardened

The third technique is to harden the password by hashing the hash.  This process should be repeated a minimum of 1,000 times according to the [RSA PKCS5 standard](http://tools.ietf.org/html/rfc2898#section-4.2).  

```
hash(hash(hash(hash(...hash(password + salt)))))
```

The goal is that this process increases the amount of time an attacker's script needs to spend hashing passwords, thus slowing down the attack.  Further, as server hardware improves the recommended amount of iterations will need to increase.

### Ruby example

The [OWASP website](https://www.owasp.org/index.php/Hashing_Java) gives a full example for using these techniques in Java. Below is an example of what the same hashing function looks like in Ruby.

```ruby
def compute_hash(password, salt)
  digestor = Digest::SHA1.new
  input = digestor.digest(salt + password)

  1000.times.inject(input) do |reply|
    digestor.digest(reply)
  end
end
```

Note that the `SHA1` algorithm can be switched for a more secure one such as `SHA256` or `SHA512` by requiring `'digest/sha2'`.

### Rails

Armed with this knowledge, let's look at how the Rails framework helps us solve this problem.  As of Rails 3.1 [has_secure_password](https://github.com/rails/rails/blob/master/activemodel/lib/active_model/secure_password.rb) provides a simple interface to use [bcrypt](https://github.com/codahale/bcrypt-ruby) for hashing passwords.  Bcrypt gives a nice interface for creating and comparing salted and hashed passwords.  

To handle hardening, Bcrypt has a option called cost which will harden your password. By default the factor is 10 which works out to 1,024 iterations, 2^10.  Also, the cost is encoded in the resulting hash so it can be increased overtime and existing passwords will continue to work.

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

Security standards are important to keep up on.  Thankfully the most common tools in the Rails ecosystem, [has_secure_password](https://github.com/rails/rails/blob/master/activemodel/lib/active_model/secure_password.rb) and [Devise](https://github.com/plataformatec/devise), use these recommended techniques.  However, it is still good to know the principles when evaluating authentication systems or building password hashing in another language.
