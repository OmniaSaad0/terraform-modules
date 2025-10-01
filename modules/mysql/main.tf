# MySQL EC2 Instance
resource "aws_instance" "mysql" {
  ami                    = var.mysql_ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  user_data = base64encode(<<-EOF
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
              CREATE DATABASE IF NOT EXISTS wordpress;
              DROP USER IF EXISTS 'admin'@'%';
              CREATE USER 'admin'@'%' IDENTIFIED BY 'Pass1234';
              GRANT ALL PRIVILEGES ON wordpress.* TO 'admin'@'%';
              CREATE USER 'admin'@'localhost' IDENTIFIED BY 'Pass1234';
              GRANT ALL PRIVILEGES ON wordpress.* TO 'admin'@'localhost';
              FLUSH PRIVILEGES;
              EOL
              
              sudo mysql < /tmp/mysql_setup.sql 2>&1 | tee /tmp/mysql_setup.log
              
              sudo mysql -e "SELECT User, Host FROM mysql.user WHERE User='admin';" 2>&1 | tee /tmp/mysql_users.log
              sudo mysql -e "SHOW DATABASES;" 2>&1 | tee /tmp/mysql_databases.log
              
              sudo systemctl restart mysql
              
              sudo rm /tmp/mysql_setup.sql
              EOF
  )

  tags = {
    Name = "${var.name_prefix}-MySQL-Server"
  }
}
