# OpenStack Keystone 2024.2 (Dalmation) Container Images

## Running Locally via Docker

Clone the repo.
```bash
git clone git@github.com:RPT-OpenStack/docker-keystone.git
git checkout origin/2024.2
```

Make relevant changes to keys / config in /etc directory.

WARNING: Do not re-use the keys already present in this repo, they are just for demonstration purposes, you should generate your own Fernet keys!

Run docker compose up
```bash
docker compose up
```

Wait for containers to come up and run DB migrations, you can tell this is complete
by fetching http://localhost:5000 with curl, should look something like this...
```bash
curl localhost:5000
{"versions": {"values": [{"id": "v3.14", "status": "stable", "updated": "2020-04-07T00:00:00Z", "links": [{"rel": "self", "href": "http://localhost:5000/v3/"}], "media-types": [{"base": "application/json", "type": "application/vnd.openstack.identity-v3+json"}]}]}}%
```

Exec into the Keystone container
```bash
docker exec -it docker-keystone-keystone-1 /bin/bash
```

This should return a bash shell in the Keystone container as Keystone user that
looks something like the following
```bash
keystone@bce6244b36f2:/$
```

Run the bootstrap command replacing the ADMIN_PASS and REGION_NAME with your preferred settings, if you are using DNS hostnames you may also want to update
your URLs.
```bash
keystone-manage bootstrap --bootstrap-password ADMIN_PASS \
  --bootstrap-admin-url http://localhost:5000/v3/ \
  --bootstrap-internal-url http://localhost:5000/v3/ \
  --bootstrap-public-url http://localhost:5000/v3/ \
  --bootstrap-region-id REGION
```

Once executed hit ctrl+d to exit the container's shell. You can now call Keystone from OpenStack client on your machine.

## Install OpenStack Client
You probably want to run this in a VirtualEnv...

```bash
python3 -m venv ~/.osvenv
source ~/.osvenv/bin/activate
```

Install OpenStack client via PIP
```bash
pip install python-openstackclient
```

## Confirm Functionality with OpenStack Client
Export your admin credentials as environment variables.
```bash
export OS_USERNAME=admin
export OS_PASSWORD=ADMIN_PASS
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://localhost:5000/v3
export OS_IDENTITY_API_VERSION=3
```

### List OpenStack Services.
```bash
openstack service list
```

Should return the Keystone Identity service if bootstrapped successfully, e.g.
```bash
+----------------------------------+----------+----------+
| ID                               | Name     | Type     |
+----------------------------------+----------+----------+
| 32b59a648e1949a1bcc569f148871ea0 | keystone | identity |
+----------------------------------+----------+----------+
```

### List users (following bootstrap only admin)
```bash
openstack user list
```

```bash
+----------------------------------+-------+
| ID                               | Name  |
+----------------------------------+-------+
| 3bf000214a634724b74392727d55c87c | admin |
+----------------------------------+-------+
```

### Attempt to Generate an Identity Token
```bash
openstack token issue
```

```bash
+------------+-----------------------------------------------------------------------------------------------------------------+
| Field      | Value                                                                                                           |
+------------+-----------------------------------------------------------------------------------------------------------------+
| expires    | 2025-03-22T19:36:47+0000                                                                                        |
| id         | gAAAAABn3wM_XWSL3FGBfLZtRY4NRicpwkrRCQi6eLwZKylKCw4az2ZKEL6o7CWC7jIYE3xIjrspdkDWolzm5fKRIN8O1dpEefEhhB5L8KSTUIt |
|            | uIsDCRwObwoEfPWyLZHld4H4A_IqXSzjofjET0bMwV4zTrzfeh17NtiWo1llzUvDnu5EMea0                                        |
| project_id | 8897f3eb6224420faa642c18456c1ae0                                                                                |
| user_id    | 3bf000214a634724b74392727d55c87c                                                                                |
+------------+-----------------------------------------------------------------------------------------------------------------+
```
