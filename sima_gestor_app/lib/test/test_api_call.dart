import 'dart:io';

import '../classes/usuario.dart';
import '../classes/abastecimento.dart';
import '../classes/api_call.dart';
import '../classes/despesas.dart';
import '../classes/checklist.dart';
import '../classes/item_checklist.dart';

void main() async {
  Usuario user = Usuario(servidor: 'simasat');
  user.setEmail("talesuriel@gmail.com");
  user.setSenha("123456");

  APICall api = APICall(null, null);
  dynamic r = await api.enviarLogin(user.toJson());
  if (r == null) {
    print("test failed :c");
    return;
  }

  Usuario logged = Usuario.fromJson(r);
  logged.realizarLogin(api.getToken());
  print("usuario logado:");
  print(logged);

  dynamic rm = await api.receberMotoristas();
  if (rm == null) {
    print("test failed :c");
    return;
  }
  print("\nlista de motoristas: ");
  print(rm);

  dynamic rv = await api.receberVeiculos();
  if (rv == null) {
    print("test failed :c");
    return;
  }
  print("\nlista de veiculos: ");
  rv.forEach((veiculo) {
    print(veiculo['placa']);
  });

  Abastecimento abastecimento = Abastecimento(
    'SUS2O20',
    DateTime.now(),
    333.33,
    'Energia',
    0.20,
    5000,
  );
  print(abastecimento);
  dynamic ra = await api.enviarAbastecimento(
    abastecimento.buildAbastecimento(),
  );
  if (ra == null) {
    print("test failed :c");
    return;
  }
  print('\nabastecimento: ');
  print(ra);

  Despesa despesa = Despesa(
    id: 2,
    placa: "SUS2O20",
    dataHora: DateTime.now(),
    tipoDespesa: "Pedágio",
    valor: 222.22,
    observacao: "observação",
    recorrente: false,
  );
  dynamic rd = await api.enviarDespesa(despesa.buildDespesa());
  if (rd == null) {
    print("test failed :c");
    return;
  }
  print("\nDespesa:");
  print(rd);
  /* OBS: teste burlado pq parece que o problema é na ponta do servidor do cara.
  dynamic rtc = await api.receberItensChecklist(1);
  if(rtc == null) {
    print("test failed :c");
    return;
  }
  print("\ntemplates checklist: ");
  print(rtc);
  */
  File foto = File("C:\\Users\\connivia\\Downloads\\fp.png");
  ItemCheckList item1 = new ItemCheckList(id: 1, nome: 'Verificar freios');
  item1.alterarStatus();
  item1.setComentario('ok');
  ItemCheckList item2 = new ItemCheckList(
    id: 2,
    nome: 'Checar pneus (pressão e desgaste)',
  );
  item2.setComentario('não ok');
  item2.setFoto(foto);
  CheckList checklist = new CheckList(
    id: null,
    idVeiculo: 22,
    idMotorista: 23,
    nomeVerificador: 'gustavo lima',
    assinaturaBase64: 'cGluZGFtb25oYW5nYWJh',
  );
  checklist.addItensChecklist(item1);
  checklist.addItensChecklist(item2);

  dynamic rc = await api.enviarChecklist(checklist.buildChecklist());
  if (rc == null) {
    print("test failed :c");
    return;
  }

  print("\nchecklist: ");
  print(rc);

  print("\ntest success :D");
}
