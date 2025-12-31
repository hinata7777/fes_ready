class NameNormalizer
  # ActiveRecordではなく、文字列正規化を担当する値オブジェクト
  # normalize: Song の名前正規化用
  # strip_presence: Artist のID整形用
  def self.strip_presence(value)
    value&.strip.presence
  end

  def self.normalize(value)
    base = value.to_s.strip
    # Unicode正規化が利用可能なら実行（環境によってunicode_normalize拡張が無い場合がある）
    base = base.unicode_normalize(:nfkc) if base.respond_to?(:unicode_normalize)

    base.mb_chars
        .downcase
        .to_s
        .gsub(/\s+/, " ")
  end
end
