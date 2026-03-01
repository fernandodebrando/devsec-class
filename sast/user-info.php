<?php
// user_info.php - Simples script PHP com acesso a DB

// Simulação de conexão com o banco de dados
$link = mysqli_connect("localhost", "user", "pass", "appdb");

// Obter um ID de usuário da URL (entrada não confiável)
$user_id = $_GET['id'];

// VULNERABILIDADE: Variável de usuário não sanitizada é inserida diretamente na query.
// Um atacante pode enviar: ?id=1' OR 1=1 --
$sql = "SELECT username, email FROM users WHERE id = " . $user_id;

$result = mysqli_query($link, $sql); // O Semgrep deve apontar esta linha!

if ($result) {
    if ($row = mysqli_fetch_assoc($result)) {
        echo "Usuário: " . htmlspecialchars($row['username']) . "<br>";
        echo "Email: " . htmlspecialchars($row['email']);
    } else {
        echo "Usuário não encontrado.";
    }
} else {
    echo "Erro na consulta ao banco de dados: " . mysqli_error($link);
}

mysqli_close($link);
?>