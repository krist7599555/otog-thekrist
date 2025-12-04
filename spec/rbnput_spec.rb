RSpec.describe Rbnput do
  it "has a version number" do
    expect(Rbnput::VERSION).not_to be nil
  end

  it "has a logger method" do
    expect(Rbnput).to respond_to(:logger)
  end
end
