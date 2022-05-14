terraform {
  backend "remote" {
  }
}

provider "aws" {
  region = "ap-northeast-1"
}