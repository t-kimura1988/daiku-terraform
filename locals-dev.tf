locals {
  dev = {
    vpc_cidr                   = "10.213.0.0/16"
    s3_alb_bucket_name         = "dev-alb-daiku-23482394820000000"
    enable_deletion_protection = false
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
        cpu                   = "1024",
        memory                = "2048",
        ecs_service_name      = "daiku-app",
        retention_in_days     = 14,
        app_lb_name           = "daiku-app-lb",
        alb_target_group_name = "daiku-app-lb-sg",
        route53_record_name   = "daikuapidev",
        ecr_name              = "daiku-app"
      },
    }

    ecs_batch_task = {
      daiku-batch = {
        family            = "daiku-batch",
        cpu               = "256",
        memory            = "512",
        ecr_name          = "daiku-batch",
        ecs_service_name  = "daiku-batch",
        retention_in_days = 14

      },
    }

    ssm_string_parameter = {
      FIRESTORE_URL       = "https://goen-dev-new.firebaseio.com",
      FIREBASE_TYPE       = "service_account",
      FIREBASE_PROJECT_ID = "goen-dev-new",
      DB_URL              = "jdbc:postgresql://dev-daiku-db.crdgrq0punfn.ap-northeast-1.rds.amazonaws.com:5432/daikudb",
      DB_USERNAME         = "devdaikuuser1"
    }

    ssm_secure_string_parameter = {
      FIREBASE_PRIVATE_KEY_ID      = "dummy",
      FIREBASE_PRIVATE_KEY         = "dummy",
      FIREBASE_CLIENT_EMAIL        = "dummy",
      FIREBASE_CLIENT_ID           = "dummy",
      FIREBASE_CLIENT_X509_CER_URL = "dummy",
      DB_PASSWORD                  = "dummy",
      API_KEY_VALUE_IOS            = "dummy"
    }

    route53_zone_name = "dev.goenway.com"

    rds_setting = {
      instance_class = "db.t3.small"
    }

  }
}