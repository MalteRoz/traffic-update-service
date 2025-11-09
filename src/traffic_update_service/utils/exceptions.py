"""Custom exceptions for the Traffic Update Service."""


class TrafficServiceException(Exception):
    """Base exception for all traffic service related errors."""
    
    def __init__(self, message: str = "An error occurred in the traffic service"):
        self.message = message
        super().__init__(self.message)


class EmptyDataException(TrafficServiceException):
    """Raised when the API returns no data or empty results.
    
    Example:
        When ResRobot API returns a response without the 'Trip' key,
        or when the trip list is empty.
    """
    
    def __init__(self, message: str = "No traffic data found in API response"):
        super().__init__(message)


class ExternalApiException(TrafficServiceException):
    """Raised when external API calls fail.
    
    This includes network errors, timeouts, HTTP errors (4xx, 5xx),
    and other request-related issues.
    """
    
    def __init__(self, message: str = "External API request failed", status_code: int | None = None):
        self.status_code = status_code
        if status_code:
            message = f"{message} (Status code: {status_code})"
        super().__init__(message)


class ApiResponseException(TrafficServiceException):
    """Raised when API response format is unexpected or invalid.
    
    Example:
        When the API returns data in an unexpected structure
        or with missing required fields.
    """
    
    def __init__(self, message: str = "Invalid or unexpected API response format"):
        super().__init__(message)


class DataParsingException(TrafficServiceException):
    """Raised when parsing API data fails.
    
    Example:
        When trying to extract trip information but required fields
        are missing or in wrong format.
    """
    
    def __init__(self, message: str = "Failed to parse API data", field: str | None = None):
        self.field = field
        if field:
            message = f"{message}: {field}"
        super().__init__(message)


class ConfigurationException(TrafficServiceException):
    """Raised when configuration is missing or invalid.
    
    Example:
        When required environment variables like API keys or URLs
        are not set or are invalid.
    """
    
    def __init__(self, message: str = "Invalid or missing configuration"):
        super().__init__(message)

