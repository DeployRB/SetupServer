[&larr; Index](../README.md)

## How to create a server on Digital Ocean

If you don't have an account on Digital Ocean you can get 10$ credit. Just sign up with the link:

**[Sign up and get 10$ credit](https://m.do.co/c/b8a4737a342d)**

#### 1. Visit [Droplets](https://cloud.digitalocean.com/droplets?refcode=b8a4737a342d) page

![fig. 1](1.png)

and

![fig. 1.1](1.1.png)

#### 2. Press the button "Create Droplet"

#### 3. Choose image, size and datacenter region

![fig. 2](2.png)

![fig. 3](3.png)

#### 4. Add your SSH key

![fig. 4](4.png)

![fig. 5](5.png)

To check existed files you can use command

```
ls -al ~/.ssh/
```

If you don't have any keys then follow this link https://help.github.com/articles/generating-an-ssh-key/

![fig. key-2](key-2.png)

To get public part of the key usually you can do this:

```sh
cat ~/.ssh/id_rsa.pub
```

![fig. 5.1](5.1.png)

![fig. 5.2](5.2.png)

#### 5. Press button "Create Droplet"

![fig. 5.3](5.3.png)

In a few seconds you will see your new server and you get a new IP.

It could be somthing like this `257.123.45.67`

![fig. 6](6.png)

#### 6. Visit your server

To visit your server can use the following command

```sh
ssh root@257.123.45.67 -i ~/.ssh/id_rsa
```

or just

```sh
ssh root@257.123.45.67
```

![fig. 7](7.png)

#### Go further

See also [How to setup a server on DO](../article-2/README.md)
