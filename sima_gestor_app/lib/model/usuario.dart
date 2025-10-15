class Usuario {
  // Atributos principais do usuário
  int? id;
  String? nome;
  String? email;
  String? senha;
  String servidor; // URL do servidor/API específico do cliente
  String? token; // Token de autenticação (JWT ou similar)
  DateTime? dataHoraLogin; // Data e hora do último login
  
  // Construtor
  Usuario({
    this.id,
    this.nome,
    this.email,
    this.senha,
    required this.servidor,
    this.token,
    this.dataHoraLogin,
  });

  // Construtor a partir de JSON (para resposta da API)
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int?,
      nome: json['nome'] as String,
      email: json['email'] as String?,
      servidor: json['servidor'] as String,
      token: json['token'] as String?
    );
  }

  // Método para converter para JSON (para envio à API)
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'senha': senha,
      'servidor': servidor,
    };
  }

  int? getId() {
    return id;
  }

  void setId(int id) {
    this.id = id;
  }

  String? getNome() {
    return nome;
  }

  void setNome(String nome) {
    this.nome = nome;
  }

  String? getEmail() {
    return email;
  }

  void setEmail(String email) {
    this.email = email;
  }

  String? getSenha() {
    return senha;
  }

  void setSenha(String? senha) {
    this.senha = senha;
  }

  String getServidor() {
    return servidor;
  }

  void setServidor(String servidor) {
    this.servidor = servidor;
  }

  String? getToken() {
    return token;
  }

  // AKA setToken(token) 
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

  @override
  String toString() {
    return 'Usuario{id: $id, nome: $nome, email: $email, servidor: $servidor, autenticado: $estaAutenticado}';
  }
}