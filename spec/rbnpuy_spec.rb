RSpec.describe Rbnpuy do
  it "has a version number" do
    expect(Rbnpuy::VERSION).not_to be nil
  end

  it "has a logger method" do
    expect(Rbnpuy).to respond_to(:logger)
  end
end
