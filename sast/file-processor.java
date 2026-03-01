import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.IOException;

public class FileProcessor {

    // Método que recebe o nome de um arquivo para ser 'listado' ou 'executado'
    public String executeExternalCommand(String filename) {
        String result = "";
        try {
            // VULNERABILIDADE: O 'filename' vem de uma fonte não confiável
            // e é diretamente concatenado para formar o comando do sistema.
            // Ex: Se 'filename' for "arquivo.txt; ls -la", o atacante injeta código.
            String command = "ls -l " + filename; 

            Process process = Runtime.getRuntime().exec(command); // O Semgrep/SonarQube deve apontar esta linha!

            BufferedReader reader = new BufferedReader(
                    new InputStreamReader(process.getInputStream()));
            
            String line;
            while ((line = reader.readLine()) != null) {
                result += line + "\n";
            }
            
            reader.close();

        } catch (IOException e) {
            e.printStackTrace();
            result = "Erro ao executar comando.";
        }
        return result;
    }

    public static void main(String[] args) {
        // Simulação de chamada de função com entrada de usuário (ex: um parâmetro de API)
        FileProcessor fp = new FileProcessor();
        // A entrada pode ser algo como: "meu_arquivo.txt; rm -rf /"
        System.out.println(fp.executeExternalCommand("temp.log"));
    }
}