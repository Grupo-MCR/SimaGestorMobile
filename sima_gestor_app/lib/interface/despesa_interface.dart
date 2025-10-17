import 'package:flutter/material.dart';

// Se a classe Despesas não for necessária por enquanto, podemos comentar ou remover esta linha:
// import '../model/despesas.dart'; 

class InterfaceDespesas extends StatefulWidget {
  const InterfaceDespesas({Key? key}) : super(key: key);

  @override
  State<InterfaceDespesas> createState() => _InterfaceDespesasState();
}

class _InterfaceDespesasState extends State<InterfaceDespesas> {
  // Controladores para os campos de texto (TextFields)
  final TextEditingController _placaController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _dataHoraController = TextEditingController();
  final TextEditingController _observacaoController = TextEditingController();
  
  // Variável para o Dropdown
  String? _tipoDespesaSelecionado;
  final List<String> _tiposDespesa = ['Pedágio', 'Combustível', 'Manutenção', 'Outros']; // Exemplo de opções

  // Variável para o Checkbox
  bool _recorrente = false;

  // Estilo de decoração para os campos de texto para replicar o visual 'dark'
  final InputDecoration _inputDecoration = InputDecoration(
    // Estilo para a borda quando o campo está habilitado e não focado
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white54, width: 0.5),
      borderRadius: BorderRadius.circular(5.0),
    ),
    // Estilo para a borda quando o campo está focado
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 1.0),
      borderRadius: BorderRadius.circular(5.0),
    ),
    // Cor de preenchimento (background do campo)
    filled: true,
    fillColor: Colors.grey[800], // Um cinza escuro para o preenchimento
    
    // Cor e estilo para o texto da dica (hint)
    hintStyle: TextStyle(color: Colors.white54),
    // Padding interno (ajuste visual)
    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
  );

  @override
  void initState() {
    super.initState();
    // Garante que o valor inicial do dropdown nunca seja nulo
    _tipoDespesaSelecionado = _tiposDespesa.first;
  }
  
  @override
  Widget build(BuildContext context) {
    // Define o background geral da tela como cinza escuro
    return Scaffold(
      backgroundColor: Colors.grey[850], // Cor de fundo principal, similar ao print
      
      // AppBar com o título "Cadastro de Despesa"
      appBar: AppBar(
        title: Text(
          'Cadastro de Despesa', 
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Colors.grey[850], // Mesma cor de fundo para a AppBar
        elevation: 0, // Remove a sombra
        automaticallyImplyLeading: true, // Adiciona botão de voltar
      ),

      // Corpo da tela (formulário)
      body: SingleChildScrollView( // Permite rolar se o conteúdo for muito grande
      padding: const EdgeInsets.all(20.0),
      child: Column(
        // Mantém o alinhamento principal à esquerda para o formulário
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: <Widget>[
          // **********************************************
          // ** INÍCIO DA CORREÇÃO: CENTRALIZAR OS TÍTULOS **
          // **********************************************
          Center( // Este widget centraliza seu filho
            child: Column(
              children: <Widget>[
                // Título principal "Despesas"
                Text(
                  'Despesas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // Subtítulo "Cadastrar Despesa"
                Text(
                  'Cadastrar Despesa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          // ********************************************
          // ** FIM DA CORREÇÃO **
          // ********************************************
          
          const SizedBox(height: 20),

            // Layout dos campos "Placa" e "Valor" lado a lado (Row com Expanded)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Campo Placa
                Expanded(
                  child: _buildTextFieldWithLabel(
                    label: 'Placa',
                    hintText: 'Ex: ABC1234',
                    controller: _placaController,
                  ),
                ),
                const SizedBox(width: 15),
                // Campo Valor
                Expanded(
                  child: _buildTextFieldWithLabel(
                    label: 'Valor',
                    hintText: '',
                    controller: _valorController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Layout dos campos "Data e Hora" e "Observação" lado a lado (Row com Expanded)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Campo Data e Hora
                Expanded(
                  child: _buildTextFieldWithLabel(
                    label: 'Data e Hora',
                    hintText: 'dd/mm/aaaa',
                    controller: _dataHoraController,
                  ),
                ),
                const SizedBox(width: 15),
                // Campo Observação
                Expanded(
                  child: _buildTextFieldWithLabel(
                    label: 'Observação',
                    hintText: '',
                    controller: _observacaoController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Campo Tipo de Despesa (Dropdown)
            _buildDropdownWithLabel(),
            const SizedBox(height: 15),

            // Checkbox "Recorrente?"
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Recorrente?',
                  style: TextStyle(color: Colors.white),
                ),
                Checkbox(
                  value: _recorrente,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _recorrente = newValue ?? false;
                    });
                  },
                  activeColor: Colors.blue, // Cor do checkbox quando selecionado
                  checkColor: Colors.white,
                  fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.blue; // Cor de preenchimento quando selecionado
                    }
                    return Colors.grey[800]!; // Cor de preenchimento quando não selecionado (similar ao campo)
                  }),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Botão "Cadastrar"
            SizedBox(
              width: double.infinity, // Ocupa toda a largura
              child: ElevatedButton(
                onPressed: () {
                  // **FUNÇÃO VAZIA: A lógica será implementada no backend**
                  // Você pode adicionar um print aqui para confirmar que o clique funciona:
                  // print('Botão Cadastrar Clicado!'); 
                },
                child: const Text('Cadastrar', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Cor de fundo do botão (azul)
                  foregroundColor: Colors.white, // Cor do texto do botão
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Função utilitária para criar um campo de texto com label
  Widget _buildTextFieldWithLabel({
    required String label,
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: Colors.white), // Cor do texto digitado
          decoration: _inputDecoration.copyWith(
            hintText: hintText,
          ),
        ),
      ],
    );
  }

  // Função utilitária para criar o Dropdown com label
  Widget _buildDropdownWithLabel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Despesa',
          style: TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            color: Colors.grey[800], // Cor de fundo do Dropdown (igual ao TextField)
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: Colors.white54, width: 0.5), // Borda
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _tipoDespesaSelecionado,
              icon: Icon(Icons.arrow_drop_down, color: Colors.white70), // Ícone do dropdown
              dropdownColor: Colors.grey[800], // Cor de fundo das opções
              style: TextStyle(color: Colors.white, fontSize: 16),
              
              onChanged: (String? newValue) {
                setState(() {
                  _tipoDespesaSelecionado = newValue;
                });
              },
              
              items: _tiposDespesa.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}