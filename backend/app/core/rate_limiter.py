import time
from collections import defaultdict
from threading import Lock
from typing import Dict, List
from fastapi import HTTPException, Request, status
from app.core.config import settings

class InMemoryRateLimiter:
    """
    Thread-safe, sliding-window rate limiter per client IP or authenticated subject.
    Protects AI inference and forensic endpoints against abuse.
    """
    def __init__(self, requests_per_minute: int = 60):
        self.requests_per_minute = requests_per_minute
        self.window_seconds = 60.0
        self._history: Dict[str, List[float]] = defaultdict(list)
        self._lock = Lock()

    def __call__(self, request: Request):
        now = time.time()
        # Key on Authorization token, X-API-Key, or Client IP
        client_key = (
            request.headers.get("X-API-Key")
            or request.headers.get("Authorization", "").split()[-1]
            or (request.client.host if request.client else "unknown_client")
        )

        with self._lock:
            timestamps = self._history[client_key]
            # Prune timestamps outside window
            cutoff = now - self.window_seconds
            pruned = [ts for ts in timestamps if ts > cutoff]

            if len(pruned) >= self.requests_per_minute:
                oldest = pruned[0]
                retry_after = int(self.window_seconds - (now - oldest)) + 1
                raise HTTPException(
                    status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                    detail=f"Rate limit exceeded: maximum {self.requests_per_minute} requests per minute.",
                    headers={
                        "Retry-After": str(retry_after),
                        "X-RateLimit-Limit": str(self.requests_per_minute),
                        "X-RateLimit-Remaining": "0"
                    }
                )

            pruned.append(now)
            self._history[client_key] = pruned

# Global default rate limiter instance
default_rate_limiter = InMemoryRateLimiter(requests_per_minute=settings.RATE_LIMIT_PER_MINUTE)
