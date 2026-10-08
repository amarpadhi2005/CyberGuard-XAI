from abc import ABC, abstractmethod
from typing import Any
from app.models.analysis import AnalysisResponse

class BaseAnalysisModel(ABC):
    """
    Abstract interface for all cybersecurity forensic & AI analysis models.
    Enables pluggable architecture so models can be swapped (e.g. from heuristic/rule-based
    to PyTorch, ONNX, or Cloud LLM) without altering endpoint contracts.
    """
    @property
    @abstractmethod
    def model_name(self) -> str:
        pass

    @property
    @abstractmethod
    def model_version(self) -> str:
        pass

    @abstractmethod
    async def analyze(self, target: Any, **kwargs) -> AnalysisResponse:
        pass
