# MySQL EC2 Instance
resource "aws_instance" "mysql" {
  ami                    = var.mysql_ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  user_data = var.enable_user_data ? base64encode(
    var.custom_user_data != "" ? var.custom_user_data : <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y mysql-server
              
              sudo systemctl start mysql
              sudo systemctl enable mysql
              
              sleep 30
              
              sudo sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
              
              sudo systemctl restart mysql
              sleep 10
              
              sudo cat > /tmp/mysql_setup.sql << 'EOL'
              CREATE DATABASE IF NOT EXISTS ${var.database_name};
              DROP USER IF EXISTS '${var.database_user}'@'%';
              CREATE USER '${var.database_user}'@'%' IDENTIFIED BY '${var.database_password}';
              GRANT ALL PRIVILEGES ON ${var.database_name}.* TO '${var.database_user}'@'%';
              CREATE USER '${var.database_user}'@'localhost' IDENTIFIED BY '${var.database_password}';
              GRANT ALL PRIVILEGES ON ${var.database_name}.* TO '${var.database_user}'@'localhost';
              FLUSH PRIVILEGES;
              EOL
              
              sudo mysql < /tmp/mysql_setup.sql 2>&1 | tee /tmp/mysql_setup.log
              
              sudo mysql -e "SELECT User, Host FROM mysql.user WHERE User='${var.database_user}';" 2>&1 | tee /tmp/mysql_users.log
              sudo mysql -e "SHOW DATABASES;" 2>&1 | tee /tmp/mysql_databases.log
              
              sudo systemctl restart mysql
              
              sudo rm /tmp/mysql_setup.sql
              EOF
  ) : null

  tags = merge({
    Name = "${var.name_prefix}-MySQL-Server"
  }, var.additional_tags)
}
