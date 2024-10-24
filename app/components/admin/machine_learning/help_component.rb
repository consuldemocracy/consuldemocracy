class Admin::MachineLearning::HelpComponent < ApplicationComponent
  private

    def instructions
      <<~INSTRUCTIONS
        sudo apt update
        sudo apt install software-properties-common
        sudo add-apt-repository ppa:deadsnakes/ppa
        sudo apt install python3.7
        sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.7 1
        curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
        python get-pip.py
        sudo update-alternatives --install /usr/bin/pip pip /home/deploy/.local/bin/pip3.7 1
        pip install pandas
      INSTRUCTIONS
    end
end
