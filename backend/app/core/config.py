from typing import List
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "CyberGuard XAI Engine"
    API_V1_STR: str = "/api/v1"
    
    # Supabase Secrets
    SUPABASE_URL: str = "https://mock.supabase.co"
    SUPABASE_ANON_KEY: str = "mock_anon_key"
    SUPABASE_SERVICE_ROLE_KEY: str = "mock_service_role"
    SUPABASE_JWT_SECRET: str = "super-secret-jwt-token-key-for-development"

    # Authentication & API Keys (Private - Never exposed to client)
    BACKEND_API_KEY: str = "cyberguard_secret_api_key_2026_dev"
    RATE_LIMIT_PER_MINUTE: int = 60

    # Model & Engine Secrets (Stored server-side only)
    MODEL_PROVIDER: str = "local_heuristic"
    AI_MODEL_SECRET_KEY: str = "cg_ai_secret_mock_key_secure_server_only"

    # CORS
    BACKEND_CORS_ORIGINS: List[str] = ["*"]

    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()
