public repo of node application :- 
https://github.com/hemal-bhatti/simple-node-react-app


http://3.108.63.140/


http://3.108.63.140/api/users

sample nginx file  :-

  GNU nano 6.2                                                                                             simple-backend.conf *                                                                                                     
server {
    server_name _;
    root /var/www/simple-app/simple-backend;

    index index.html index.htm index.nginx-debian.html;

    client_max_body_size 100M;

    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options SAMEORIGIN always;
    server_tokens off;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_connect_timeout 60s;
        proxy_read_timeout 5400s;
        proxy_send_timeout 5400s;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

}



attach policy to ec2 of CloudWatchAgentServerPolicy 



install cw agent for logs :-  
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb