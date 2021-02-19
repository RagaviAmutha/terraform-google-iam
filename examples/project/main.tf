/**
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/******************************************
  Provider configuration
 *****************************************/

terraform {
  # backend "gcs" {
  #   bucket  = "state_files"
  #   prefix  = "terraform/state"
  # }
  backend "remote" {
    organization = "scale-org-1"

  workspaces {
    name = "project-iam"
    }
  }
}
provider "google" {
  version = "~> 3.36"
}

provider "google-beta" {
  version = "~> 3.36"
}

/******************************************
  Module project_iam_binding calling
 *****************************************/
module "iam_projects_iam" {
  source  = "app.terraform.io/scale-org-1/iam/google//modules/projects_iam"
  version = "6.4.1"
  projects = [var.project_one]
  mode     = "additive"
  #count = length(var.roles_members)
  for_each = var.roles_members
  
  for role in ${each.value} : {
    bindings = {
      "roles/${role}" = [
        # "serviceAccount:${var.sa_email}",
        # "group:${var.group_email}",
        "user:${each.key}",
      ]
      # "roles/appengine.appAdmin" = [
      #   "serviceAccount:${var.sa_email}",
      #   "group:${var.group_email}",
      #   "user:${var.user_email}",
      # ]
    }
  }
}

