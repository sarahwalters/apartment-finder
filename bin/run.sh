sudo docker build -t "afinder:latest" . &&
sudo docker run -d --env-file ./config/credentials.list afinder
