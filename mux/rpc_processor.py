from jrpc.service import JsonRpcProcessor, MethodHandler, MethodSet, TypedMethodHandler

from .api import MuxMethod
from .service import MuxApi


def mux_rpc_processor(impl: MuxApi) -> JsonRpcProcessor:
    handlers: list[TypedMethodHandler] = [
        TypedMethodHandler(MuxMethod.GET_MULTIPLE, impl.get_multiple),
        TypedMethodHandler(MuxMethod.GET_ALL, impl.get_all),
        TypedMethodHandler(MuxMethod.RESOLVE_MULTIPLE, impl.resolve_multiple),
        TypedMethodHandler(MuxMethod.RESOLVE_ALL, impl.resolve_all),
        TypedMethodHandler(MuxMethod.SET_MULTIPLE, impl.set_multiple),
        TypedMethodHandler(MuxMethod.CLEAR_AND_REPLACE, impl.clear_and_replace),
        TypedMethodHandler(MuxMethod.LOCATION_INFO, impl.get_location_info),
    ]
    return MethodSet({m.descriptor.name: m for m in handlers})
