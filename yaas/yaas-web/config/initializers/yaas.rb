# Read or generates passwords salt
def default_salt
  salt = nil
  file_path = Rails.root.join("config", "secrets", "password_salt")

  if !File.exists?(file_path)
    file = File.open(file_path, "w")
    file.puts(SecureRandom.base64(8))
    file.close
  end

  file = File.open(file_path, "r")
  salt = file.readline().split.join("\n")
  file.close
  salt
end

# Yaas Client
YAAS_CONFIG = YAML.load_file(Rails.root.join("config", "yaas.yml"))
YAAS_CONFIG[:password_salt] = default_salt

