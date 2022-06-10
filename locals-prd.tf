locals {
  prd = {
    vpc_cidr                   = "10.213.0.0/16"
    s3_alb_bucket_name         = "alb-daiku-23482394820000000"
    enable_deletion_protection = true
    public_subnets = {
      public-1a = {
        name        = "public-1a",
        cidr        = "10.213.100.0/24",
        az          = "ap-northeast-1a",
        nat_gateway = "nat-1a"
      },
      public-1c = {
        name        = "public-1c",
        cidr        = "10.213.101.0/24",
        az          = "ap-northeast-1c",
        nat_gateway = "nat-1c"
      }
    }
    protected_subnets = {
      protected-1a = {
        name = "protected-1a",
        cidr = "10.213.10.0/24",
        az   = "ap-northeast-1a"

      },
      protected-1c = {
        name = "protected-1c",
        cidr = "10.213.11.0/24",
        az   = "ap-northeast-1c"
      }
    }
    private_subnets = {
      private-1a = {
        name = "private-1a",
        cidr = "10.213.20.0/24",
        az   = "ap-northeast-1a"

      },
      private-1c = {
        name = "private-1c",
        cidr = "10.213.21.0/24",
        az   = "ap-northeast-1c"
      }
    }
    availavility_zone = {
      ap-northeast-1a = 0
      ap-northeast-1c = 1
    }
    ecs_app_task = {
      daiku-app = {
        family                = "daiku-app",
        cpu                   = "256",
        memory                = "512",
        ecs_service_name      = "daiku-app",
        retention_in_days     = 14,
        app_lb_name           = "daiku-app-lb",
        alb_target_group_name = "daiku-app-lb-sg",
        route53_record_name   = "daikuapi",
        ecr_name              = "daiku-app"
      },
    }

    ssm_string_parameter = {
      FIRESTORE_URL       = "https://goen-daiku.firebaseio.com",
      FIREBASE_TYPE       = "service_account",
      FIREBASE_PROJECT_ID = "goen-daiku",
      DB_URL              = "jdbc:postgresql://prd-daiku-db.crdgrq0punfn.ap-northeast-1.rds.amazonaws.com:5432/daikudb",
      DB_USERNAME         = "prddaikuuser1"
    }

    ssm_secure_string_parameter = {
      FIREBASE_PRIVATE_KEY_ID      = "dummy",
      FIREBASE_PRIVATE_KEY         = "dummy",
      FIREBASE_CLIENT_EMAIL        = "dummy",
      FIREBASE_CLIENT_ID           = "dummy",
      FIREBASE_CLIENT_X509_CER_URL = "dummy",
      DB_PASSWORD                  = "dummy"
    }

    route53_zone_name = "goenway.com"

    rds_setting = {
      instance_class = "db.t3.small"
    }

  }
}