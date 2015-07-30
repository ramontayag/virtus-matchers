# Virtus Matchers

[![Build Status](https://travis-ci.org/G5/virtus-matchers.svg)](https://travis-ci.org/G5/virtus-matchers)

Matchers for Virtus

Only RSpec matchers are available now

# Usage

```
RSpec.describe Unit, type: :virtus do

  subject { described_class }
  it { is_expected.to have_attribute(:name) }
  it { is_expected.to have_attribute(:location, String) }
  it { is_expected.to have_attribute(:bedrooms, Integer).with_default(1) }
end
```

The `type: :virtus` is important. The matchers are only available when the type is `:virtus`.
