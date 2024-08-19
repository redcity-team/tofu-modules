terraform {
  required_providers {
    vkcs = {
      source  = "vk-cs/vkcs"
      version = "0.8.1"
    }
    ansible = {
      version = "1.3.0"
      source  = "ansible/ansible"
    }
  }
}