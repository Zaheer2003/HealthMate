from diagrams import Diagram, Cluster
from diagrams.aws.security import Cognito
from diagrams.aws.storage import S3
from diagrams.custom import Custom
from diagrams.onprem.database import PostgreSQL
from diagrams.programming.framework import Flutter
from diagrams.generic.device import Mobile
from diagrams.saas.identity import Auth0

with Diagram("HealthMate Mobile App Architecture", show=False, direction="LR") as diag:
    # Actors
    mobile_user = Mobile("User")

    # Frontend (Flutter App)
    with Cluster("HealthMate Mobile App (Flutter)"):
        flutter_app = Flutter("Main App")

        with Cluster("Features"):
            auth_feature = Custom("Auth Feature\n(Views, Widgets)", "./assets/icon/icon.png")
            health_records_feature = Custom("Health Records Feature\n(Views, Widgets)", "./assets/icon/icon.png")

        with Cluster("Application Services"):
            auth_service = Custom("Auth Service", "./assets/icon/icon.png")
            health_records_service = Custom("Health Records Service", "./assets/icon/icon.png")
            theme_provider = Custom("Theme Provider", "./assets/icon/icon.png")
            
        # Internal Connections
        flutter_app >> [auth_feature, health_records_feature, theme_provider]
        auth_feature >> auth_service
        health_records_feature >> health_records_service

    # Backend / Data Sources
    with Cluster("Backend / Data Sources"):
        external_auth_provider = Auth0("External Auth Provider\n(e.g., Firebase, Auth0, Custom API)")
        health_api = Custom("Health Records API\n(REST API)", "./assets/icon/icon.png")
        database = PostgreSQL("Database\n(e.g., PostgreSQL, MongoDB)")

    # Data Flow
    auth_service >> external_auth_provider
    health_records_service >> health_api
    health_api >> database

    # User Interaction
    mobile_user >> flutter_app
