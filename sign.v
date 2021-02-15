module libsodium

const (
	sign_len = 64
)

struct SigningKey {
	secret_key [32]byte
pub:
	verify_key VerifyKey
}

struct VerifyKey {
	public_key [32]byte
}

pub fn new_signing_key(public_key [32]byte, secret_key [32]byte) SigningKey {
	res := SigningKey{
		verify_key: {
			public_key: public_key
		}
		secret_key: secret_key
	}
	//res.secret_key = secret_key
	return res
}

pub fn generate_signing_key() SigningKey {
	res := SigningKey{}
	C.crypto_sign_keypair(res.verify_key.public_key, res.secret_key)
	return res
}

pub fn (key VerifyKey) verify_string(s string) bool {
	len := s.len - sign_len
	buf := []byte{len: len}
	mut buf_len := 0
	if C.crypto_sign_open(buf.data, &buf_len, s.str, s.len, key.public_key) != 0 {
		return false
	}
	return true
}

pub fn (key SigningKey) sign_string(s string) string {
	buf := []byte{len: sign_len + s.len}
	mut buf_len := 0
	C.crypto_sign(buf.data, &buf_len, s.str, s.len, key.secret_key)
	return string(buf)
}

pub fn (key VerifyKey) verify(b []byte) bool {
	len := b.len - sign_len
	buf := []byte{len: len}
	mut buf_len := 0
	if C.crypto_sign_open(buf.data, &buf_len, b.data, b.len, key.public_key) != 0 {
		return false
	}
	return true
}

pub fn (key SigningKey) sign(b []byte) []byte {
	buf := []byte{len: sign_len + b.len}
	mut buf_len := 0
	C.crypto_sign(buf.data, &buf_len, b.data, b.len, key.secret_key)
	return buf
}
