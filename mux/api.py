from dataclasses import dataclass
from typing import Mapping, Self, TypeVar

from dataclasses_json import DataClassJsonMixin
from dataclasses_json.mm import SchemaType
from jrpc.data import ParsedJson
from result import Result, Ok, Err

T = TypeVar("T")


def _try_load(
    schema_class: type[T], schema: SchemaType[T], parsed_json: ParsedJson
) -> Result[T, str]:
    if not isinstance(parsed_json, Mapping):
        return Err(
            f"Failed to load {schema_class.__name__} from schema: 'parsed_json' must be a dict"
        )
    if not isinstance(parsed_json, dict):
        parsed_json = dict(parsed_json)

    try:
        return Ok(schema.load(parsed_json, unknown="exclude"))
    except ValueError as error:
        return Err(f"Failed to load {schema_class.__name__} from schema: {error}")


class JsonTryLoadMixin(DataClassJsonMixin):
    """
    Mixin built on dataclasses-json that adds a try_load method
    """

    @classmethod
    def try_load(cls, parsed_json: ParsedJson) -> Result[Self, str]:
        return _try_load(cls, cls.schema(), parsed_json)


@dataclass
class GetMultipleParams(JsonTryLoadMixin):
    location: str
    namespace: str
    keys: list[str]


@dataclass
class GetMultipleResult(JsonTryLoadMixin):
    values: dict[str, str | None]


@dataclass
class GetAllParams(JsonTryLoadMixin):
    location: str
    namespace: str


@dataclass
class GetAllResult(JsonTryLoadMixin):
    values: dict[str, str]


@dataclass
class ResolveMultipleParams(JsonTryLoadMixin):
    location: str
    namespace: str
    keys: list[str]


@dataclass
class ResolveMultipleResult(JsonTryLoadMixin):
    values: dict[str, str | None]


@dataclass
class ResolveAllParams(JsonTryLoadMixin):
    location: str
    namespace: str


@dataclass
class ResolveAllResult(JsonTryLoadMixin):
    values: dict[str, str]


@dataclass
class SetMultipleParams(JsonTryLoadMixin):
    location: str
    namespace: str
    values: dict[str, str]


@dataclass
class SetMultipleResult(JsonTryLoadMixin):
    pass


@dataclass
class ClearAndReplaceParams(JsonTryLoadMixin):
    location: str
    namespace: str
    values: dict[str, str]


@dataclass
class ClearAndReplaceResult(JsonTryLoadMixin):
    pass


@dataclass
class LocationInfoParams(JsonTryLoadMixin):
    ref: str


@dataclass
class LocationInfoResult(JsonTryLoadMixin):
    exists: bool
    id: str | None
