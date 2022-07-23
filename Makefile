deploy:
	ansible-playbook -i hosts site.yml --ask-vault-pass