FROM alpine/ansible:2.18.1

COPY ./create_grafana_users.yml /create_grafana_users.yml

CMD ["ansible-playbook", "/create_grafana_users.yml"]