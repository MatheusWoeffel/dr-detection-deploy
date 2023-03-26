variable "description" {
    description = "Repository's short description"
}

variable "architectures" {
    description = "Target architectures of the repository"
    type = list(string)
}

variable "about_text" {
  description = "Repository's full description"   
}

variable "operating_systems" {
    description = "Target OSs of the repository"
    type = list(string)
}

variable "name"{
    description = "Repository's name"
}