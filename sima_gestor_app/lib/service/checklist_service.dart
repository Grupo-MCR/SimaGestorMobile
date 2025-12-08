import '../model/checklist.dart';
import '../model/item_checklist.dart';
import 'api_service.dart';

class ChecklistService {
  final APIService api;

  ChecklistService(this.api);

  /// Monta o objeto CheckList pronto para envio
  CheckList montarChecklist({
    required int idVeiculo,
    required int idMotorista,
    required String nomeVerificador,
    required String assinaturaBase64,
    required List<ItemCheckList> itens,
  }) {
    final checklist = CheckList(
      idVeiculo: idVeiculo,
      idMotorista: idMotorista,
      nomeVerificador: nomeVerificador,
      assinaturaBase64: assinaturaBase64,
    );

    for (final item in itens) {
      checklist.addItensChecklist(item);
    }

    if (!checklist.validarNull()) {
      throw Exception('Checklist inválido. Campos obrigatórios ausentes.');
    }

    return checklist;
  }

  /// Envia o checklist completo para o backend
  Future<bool> enviarChecklist(CheckList checklist) async {
    try {
      final data = checklist.buildChecklist();

      final response = await api.enviarChecklist(data);

      if (response == null) {
        throw Exception('Erro ao enviar checklist');
      }

      return true;
    } catch (e) {
      print('Erro ao enviar checklist: $e');
      rethrow;
    }
  }

  /// Fluxo completo: monta e envia o checklist
  Future<bool> processarChecklist({
    required int idVeiculo,
    required int idMotorista,
    required String nomeVerificador,
    required String assinaturaBase64,
    required List<ItemCheckList> itens,
  }) async {
    try {
      final checklist = montarChecklist(
        idVeiculo: idVeiculo,
        idMotorista: idMotorista,
        nomeVerificador: nomeVerificador,
        assinaturaBase64: assinaturaBase64,
        itens: itens,
      );

      return await enviarChecklist(checklist);
    } catch (e) {
      rethrow;
    }
  }
}
