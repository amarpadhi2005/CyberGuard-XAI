from typing import Optional
from fastapi import Header, HTTPException, Security, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwt
from app.core.config import settings

bearer_security = HTTPBearer(auto_error=False)

def verify_auth(
    credentials: Optional[HTTPAuthorizationCredentials] = Security(bearer_security),
    x_api_key: Optional[str] = Header(None, alias="X-API-Key")
) -> dict:
    """
    Authenticates requests from Android or authorized clients via:
    1. Valid Supabase JWT token (Bearer header)
    2. Shared Client API Key (X-API-Key header)
    3. Development demo tokens for local test suites
    """
    # 1. API Key Auth
    if x_api_key and x_api_key == settings.BACKEND_API_KEY:
        return {
            "sub": "client_api_key_app",
            "role": "service_client",
            "auth_type": "api_key"
        }

    # 2. Bearer JWT Auth
    if credentials:
        token = credentials.credentials

        # Demo / Test token bypass
        if token.startswith("demo_") or token == "test_token_valid":
            return {
                "sub": "usr_demo_12345",
                "email": "agent@cyberguard.ai",
                "role": "authenticated",
                "auth_type": "demo_jwt"
            }

        try:
            payload = jwt.decode(
                token,
                settings.SUPABASE_JWT_SECRET,
                algorithms=["HS256"],
                options={"verify_aud": False}
            )
            payload["auth_type"] = "supabase_jwt"
            return payload
        except JWTError as e:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail=f"Invalid or expired JWT token: {str(e)}",
                headers={"WWW-Authenticate": "Bearer"},
            )

    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Authentication required. Provide a valid Bearer token or X-API-Key header.",
        headers={"WWW-Authenticate": "Bearer, ApiKey"},
    )

# Alias for backwards compatibility
def verify_supabase_jwt(credentials: Optional[HTTPAuthorizationCredentials] = Security(bearer_security)) -> dict:
    return verify_auth(credentials=credentials)
