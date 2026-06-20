#!/bin/bash

apt-get update -y
apt-get install -y apache2
systemctl enable apache2
systemctl start apache2

cat <<EOF > /var/www/html/index.html
<html>
<head><title>Terraform Apache Server</title></head>
<body>
<h1>Apache Installed Successfully using Terraform!</h1>
<h2>Hostname: $(hostname)</h2>
</body>
</html>
EOF