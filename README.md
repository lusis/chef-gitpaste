# Gitpaste
Installs and configures [gitpaste](https://github.com/justinvh/gitpaste) - a private gist-alike service.
It can optionally proxy gitpaste behind an apache SSL frontend.

## Requirements
The following official Opscode cookbooks are required

- openssl
- apt
- apache2 
- python
- git
- runit

## Usage
The most basic way to run this is to add `gitpaste` to your `run_list`.
This will start the gitpaste service under `runit` listening on `node.ipaddress`:8080 under a virtualenv.

The default installation is pretty much the same out-of-the-box experience you would get running it yourself with one small change - it will use a sqlite database instead of the default pgsql.

### Running under Apache
If you'd like to run this behind Apache, also add `gitpaste::apache` to your `run_list` in addition to gitpaste:

```
recipe[gitpaste]
recipe[gitpaste::apache]
```

Note that this WILL run in SSL mode. Default certs are shipped for the hostname `gitpaste.local`.

### Google Apps OpenID Integration
The cookbook also supports openid authentication against google apps accounts. To enable this, you'll want to set the following attributes:

```ruby
node['gitpaste']['google_apps_auth'] = true
node['gitpaste']['apache']['apps_domain_regex'] = '@mydomain\.com$'
```

Note that `apps_domain_regex` is actually a perl-compatible regex as expected by `AuthOpenIDAXRequire` defined [here](http://findingscience.com/mod_auth_openid/index.html). This means if you are setting it in JSON (i.e. a role definition), you'll have to double-escape the backslash like so:

```json
{
 "gitpaste":{
  "apache":{
   "apps_domain_regex":"@mydomain\\.com$"
  }
 }
}
```

When enabling Google Apps integration, several flags are turned on in the django side to enable secure cookies. You might also want to change the value of `node['gitpaste']['apache']['cookie_name']`

## Attributes
There are a good bit of attributes that should allow you to wrap this cookbook pretty cleanly:

### `svc_type` and `svc_cookbook`
`node['gitpaste']['svc_type']` and `node['gitpaste']['svc_cookbook']` should let you create your own init setup for gitpaste should the cookbook not provide one for you. This is used to call build an `include_recipe` statement at the end of `gitpaste::install`.

### Django settings
`node['gitpaste']['settings_template']` and `node['gitpaste']['settings_cookbook']` will let you provide an alternate Django `settings.py` file.

### Apache settings
`node['gitpaste']['apache']['cookbook']` will let you define which cookbook contains the Apache config template (`node['gitpaste']['apache']['config']`)

### SSL Certs
`node['gitpaste']['ssl_cookbook']` will let you define which cookbook contains `node['gitpaste']['apache']['ssl_cert']` and `node['gitpaste']['apache']['ssl_key']`

There are plenty of attributes you can define so take a look.

## Security
I'm not a security expert but every precaution has been taken to ensure that the right thing is done. When running with gapps integration, django and apache are set to enable secure cookies and prevent javascript munging.

The Django secure token is generated randomly for each install using the `openssl` cookbook `secure_password` function.

Additionally, you should consider defining the following variables yourself to further prevent predictive attacks:

- `node['gitpaste']['apache']['cookie_name']`
- `node['gitpaste']['apache']['iddb_directory']`
- `node['gitpaste']['apache']['iddb_file']`

You can also turn off anonymous posting and access via the following attributes:

- `node['gitpaste']['allow_anonymous_posts']`
- `node['gitpaste']['allow_anonymous_access']`

Note the are not ruby `true`/`false` but Python bools as strings (`True`/`False`).

## Contributing
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

If you make a pull request and it gets merged, I'll likely give you commit rights on the cookbook. Good way to get started in open source!
## License and Authors
Authors: John E. Vincent <@lusis>
