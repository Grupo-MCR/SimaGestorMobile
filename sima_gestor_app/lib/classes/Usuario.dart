

class Usuario {
  // Atributos principais do usuário
  int? id;
  String nome;
  String email;
  String senha;
  String servidor; // URL do servidor/API específico do cliente
  String? token; // Token de autenticação (JWT ou similar)
  DateTime? dataHoraLogin; // Data e hora do último login
  String? empresa; // Nome da empresa vinculada ao usuário
  
  // Construtor
  Usuario({
    this.id,
    required this.nome,
    required this.email,
    required this.senha,
    required this.servidor,
    this.token,
    this.dataHoraLogin,
    this.empresa,
  });

  // Construtor a partir de JSON (para resposta da API)
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int?,
      nome: json['nome'] as String,
      email: json['email'] as String,
      senha: json['senha'] as String? ?? '', // Senha pode não vir na resposta
      servidor: json['servidor'] as String,
      token: json['token'] as String?,
      dataHoraLogin: json['dataHoraLogin'] != null 
          ? DateTime.parse(json['dataHoraLogin'] as String) 
          : null,
      empresa: json['empresa'] as String?,
    );
  }

  // Método para converter para JSON (para envio à API)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
      'servidor': servidor,
      if (token != null) 'token': token,
      if (dataHoraLogin != null) 
        'dataHoraLogin': dataHoraLogin!.toIso8601String(),
      if (empresa != null) 'empresa': empresa,
    };
  }

  // Método para login (atualiza token e data/hora do login)
  void realizarLogin(String novoToken) {
    token = novoToken;
    dataHoraLogin = DateTime.now();
  }

  // Método para logout (remove token e data/hora do login)
  void realizarLogout() {
    token = null;
    dataHoraLogin = null;
  }

  // Verifica se o usuário está autenticado (tem token válido)
  bool get estaAutenticado {
    if (token == null || dataHoraLogin == null) {
      return false;
    }
    
    // Verifica se o token expirou (considerando 24 horas de validade)
    final agora = DateTime.now();
    final diferenca = agora.difference(dataHoraLogin!);
    return diferenca.inHours < 24;
  }

  // Método para atualizar dados do usuário
  void atualizarDados({
    String? novoNome,
    String? novoEmail,
    String? novoServidor,
    String? novaEmpresa,
  }) {
    if (novoNome != null) nome = novoNome;
    if (novoEmail != null) email = novoEmail;
    if (novoServidor != null) servidor = novoServidor;
    if (novaEmpresa != null) empresa = novaEmpresa;
  }

  @override
  String toString() {
    return 'Usuario{id: $id, nome: $nome, email: $email, servidor: $servidor, empresa: $empresa, autenticado: $estaAutenticado}';
  }
}