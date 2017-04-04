import grpc
from grpc.framework.common import cardinality
from grpc.framework.interfaces.face import utilities as face_utilities

import nfa_msg_pb2 as nfa__msg__pb2
import nfa_msg_pb2 as nfa__msg__pb2
import nfa_msg_pb2 as nfa__msg__pb2
import nfa_msg_pb2 as nfa__msg__pb2
import nfa_msg_pb2 as nfa__msg__pb2
import nfa_msg_pb2 as nfa__msg__pb2
import nfa_msg_pb2 as nfa__msg__pb2
import nfa_msg_pb2 as nfa__msg__pb2
import nfa_msg_pb2 as nfa__msg__pb2
import nfa_msg_pb2 as nfa__msg__pb2
import nfa_msg_pb2 as nfa__msg__pb2
import nfa_msg_pb2 as nfa__msg__pb2
import nfa_msg_pb2 as nfa__msg__pb2
import nfa_msg_pb2 as nfa__msg__pb2
import nfa_msg_pb2 as nfa__msg__pb2
import nfa_msg_pb2 as nfa__msg__pb2
import nfa_msg_pb2 as nfa__msg__pb2
import nfa_msg_pb2 as nfa__msg__pb2
import nfa_msg_pb2 as nfa__msg__pb2
import nfa_msg_pb2 as nfa__msg__pb2
import nfa_msg_pb2 as nfa__msg__pb2
import nfa_msg_pb2 as nfa__msg__pb2
import nfa_msg_pb2 as nfa__msg__pb2
import nfa_msg_pb2 as nfa__msg__pb2


class Runtime_RPCStub(object):

  def __init__(self, channel):
    """Constructor.

    Args:
      channel: A grpc.Channel.
    """
    self.LivenessCheck = channel.unary_unary(
        '/nfa_msg.Runtime_RPC/LivenessCheck',
        request_serializer=nfa__msg__pb2.LivenessRequest.SerializeToString,
        response_deserializer=nfa__msg__pb2.LivenessReply.FromString,
        )
    self.AddOutputRts = channel.unary_unary(
        '/nfa_msg.Runtime_RPC/AddOutputRts',
        request_serializer=nfa__msg__pb2.AddOutputRtsReq.SerializeToString,
        response_deserializer=nfa__msg__pb2.AddOutputRtsRes.FromString,
        )
    self.AddInputRt = channel.unary_unary(
        '/nfa_msg.Runtime_RPC/AddInputRt',
        request_serializer=nfa__msg__pb2.AddInputRtReq.SerializeToString,
        response_deserializer=nfa__msg__pb2.AddInputRtRep.FromString,
        )
    self.DeleteOutputRt = channel.unary_unary(
        '/nfa_msg.Runtime_RPC/DeleteOutputRt',
        request_serializer=nfa__msg__pb2.DeleteOutputRtReq.SerializeToString,
        response_deserializer=nfa__msg__pb2.DeleteOutputRtRep.FromString,
        )
    self.DeleteInputRt = channel.unary_unary(
        '/nfa_msg.Runtime_RPC/DeleteInputRt',
        request_serializer=nfa__msg__pb2.DeleteInputRtReq.SerializeToString,
        response_deserializer=nfa__msg__pb2.DeleteInputRtRep.FromString,
        )
    self.SetMigrationTarget = channel.unary_unary(
        '/nfa_msg.Runtime_RPC/SetMigrationTarget',
        request_serializer=nfa__msg__pb2.SetMigrationTargetReq.SerializeToString,
        response_deserializer=nfa__msg__pb2.SetMigrationTargetRep.FromString,
        )
    self.MigrationNegotiate = channel.unary_unary(
        '/nfa_msg.Runtime_RPC/MigrationNegotiate',
        request_serializer=nfa__msg__pb2.MigrationNegotiateReq.SerializeToString,
        response_deserializer=nfa__msg__pb2.MigrationNegotiateRep.FromString,
        )
    self.AddReplicas = channel.unary_unary(
        '/nfa_msg.Runtime_RPC/AddReplicas',
        request_serializer=nfa__msg__pb2.AddReplicasReq.SerializeToString,
        response_deserializer=nfa__msg__pb2.AddReplicasRep.FromString,
        )
    self.ReplicaNegotiate = channel.unary_unary(
        '/nfa_msg.Runtime_RPC/ReplicaNegotiate',
        request_serializer=nfa__msg__pb2.ReplicaNegotiateReq.SerializeToString,
        response_deserializer=nfa__msg__pb2.ReplicaNegotiateRep.FromString,
        )
    self.DeleteReplica = channel.unary_unary(
        '/nfa_msg.Runtime_RPC/DeleteReplica',
        request_serializer=nfa__msg__pb2.DeleteReplicaReq.SerializeToString,
        response_deserializer=nfa__msg__pb2.DeleteReplicaRep.FromString,
        )
    self.DeleteStorage = channel.unary_unary(
        '/nfa_msg.Runtime_RPC/DeleteStorage',
        request_serializer=nfa__msg__pb2.DeleteStorageReq.SerializeToString,
        response_deserializer=nfa__msg__pb2.DeleteStorageRep.FromString,
        )
    self.GetRuntimeState = channel.unary_unary(
        '/nfa_msg.Runtime_RPC/GetRuntimeState',
        request_serializer=nfa__msg__pb2.GetRuntimeStateReq.SerializeToString,
        response_deserializer=nfa__msg__pb2.GetRuntimeStateRep.FromString,
        )


class Runtime_RPCServicer(object):

  def LivenessCheck(self, request, context):
    """Sends a greeting
    """
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def AddOutputRts(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def AddInputRt(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def DeleteOutputRt(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def DeleteInputRt(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def SetMigrationTarget(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def MigrationNegotiate(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def AddReplicas(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def ReplicaNegotiate(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def DeleteReplica(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def DeleteStorage(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def GetRuntimeState(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')


def add_Runtime_RPCServicer_to_server(servicer, server):
  rpc_method_handlers = {
      'LivenessCheck': grpc.unary_unary_rpc_method_handler(
          servicer.LivenessCheck,
          request_deserializer=nfa__msg__pb2.LivenessRequest.FromString,
          response_serializer=nfa__msg__pb2.LivenessReply.SerializeToString,
      ),
      'AddOutputRts': grpc.unary_unary_rpc_method_handler(
          servicer.AddOutputRts,
          request_deserializer=nfa__msg__pb2.AddOutputRtsReq.FromString,
          response_serializer=nfa__msg__pb2.AddOutputRtsRes.SerializeToString,
      ),
      'AddInputRt': grpc.unary_unary_rpc_method_handler(
          servicer.AddInputRt,
          request_deserializer=nfa__msg__pb2.AddInputRtReq.FromString,
          response_serializer=nfa__msg__pb2.AddInputRtRep.SerializeToString,
      ),
      'DeleteOutputRt': grpc.unary_unary_rpc_method_handler(
          servicer.DeleteOutputRt,
          request_deserializer=nfa__msg__pb2.DeleteOutputRtReq.FromString,
          response_serializer=nfa__msg__pb2.DeleteOutputRtRep.SerializeToString,
      ),
      'DeleteInputRt': grpc.unary_unary_rpc_method_handler(
          servicer.DeleteInputRt,
          request_deserializer=nfa__msg__pb2.DeleteInputRtReq.FromString,
          response_serializer=nfa__msg__pb2.DeleteInputRtRep.SerializeToString,
      ),
      'SetMigrationTarget': grpc.unary_unary_rpc_method_handler(
          servicer.SetMigrationTarget,
          request_deserializer=nfa__msg__pb2.SetMigrationTargetReq.FromString,
          response_serializer=nfa__msg__pb2.SetMigrationTargetRep.SerializeToString,
      ),
      'MigrationNegotiate': grpc.unary_unary_rpc_method_handler(
          servicer.MigrationNegotiate,
          request_deserializer=nfa__msg__pb2.MigrationNegotiateReq.FromString,
          response_serializer=nfa__msg__pb2.MigrationNegotiateRep.SerializeToString,
      ),
      'AddReplicas': grpc.unary_unary_rpc_method_handler(
          servicer.AddReplicas,
          request_deserializer=nfa__msg__pb2.AddReplicasReq.FromString,
          response_serializer=nfa__msg__pb2.AddReplicasRep.SerializeToString,
      ),
      'ReplicaNegotiate': grpc.unary_unary_rpc_method_handler(
          servicer.ReplicaNegotiate,
          request_deserializer=nfa__msg__pb2.ReplicaNegotiateReq.FromString,
          response_serializer=nfa__msg__pb2.ReplicaNegotiateRep.SerializeToString,
      ),
      'DeleteReplica': grpc.unary_unary_rpc_method_handler(
          servicer.DeleteReplica,
          request_deserializer=nfa__msg__pb2.DeleteReplicaReq.FromString,
          response_serializer=nfa__msg__pb2.DeleteReplicaRep.SerializeToString,
      ),
      'DeleteStorage': grpc.unary_unary_rpc_method_handler(
          servicer.DeleteStorage,
          request_deserializer=nfa__msg__pb2.DeleteStorageReq.FromString,
          response_serializer=nfa__msg__pb2.DeleteStorageRep.SerializeToString,
      ),
      'GetRuntimeState': grpc.unary_unary_rpc_method_handler(
          servicer.GetRuntimeState,
          request_deserializer=nfa__msg__pb2.GetRuntimeStateReq.FromString,
          response_serializer=nfa__msg__pb2.GetRuntimeStateRep.SerializeToString,
      ),
  }
  generic_handler = grpc.method_handlers_generic_handler(
      'nfa_msg.Runtime_RPC', rpc_method_handlers)
  server.add_generic_rpc_handlers((generic_handler,))
