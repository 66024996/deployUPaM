---
- name: Deploy UPaM project as Docker container
  hosts: localhost
  become: yes
  vars:
    upam_repo: "https://github.com/66024996/deployUPaM.git"
    upam_dest: "D:/deploy/UPaM"
    upam_image: "upam_app"
    upam_tag: "latest"

  tasks:

    - name: Ensure git is installed
      ansible.builtin.package:
        name: git
        state: present

    - name: Ensure Docker is installed
      ansible.builtin.package:
        name: docker.io
        state: present

    - name: Ensure pip3 is installed
      ansible.builtin.package:
        name: python3-pip
        state: present

    - name: Ensure Python Docker module is installed
      ansible.builtin.pip:
        name: docker
        state: present

    - name: Clone GitHub repository
      ansible.builtin.git:
        repo: "{{ upam_repo }}"
        dest: "{{ upam_dest }}"
        version: main
        force: yes

    - name: Check if Dockerfile exists
      ansible.builtin.stat:
        path: "{{ upam_dest }}/Dockerfile"
      register: dockerfile_check

    - name: Fail if Dockerfile is missing
      ansible.builtin.fail:
        msg: "Dockerfile not found in {{ upam_dest }}. Please add a Dockerfile."
      when: not dockerfile_check.stat.exists

    - name: Build Docker image from UPaM
      community.docker.docker_image:
        name: "{{ upam_image }}"
        tag: "{{ upam_tag }}"
        build:
          path: "{{ upam_dest }}"
        state: present

    - name: Run UPaM container
      community.docker.docker_container:
        name: "{{ upam_image }}"
        image: "{{ upam_image }}:{{ upam_tag }}"
        state: started
        restart_policy: unless-stopped
        ports:
          - "8080:3000"
