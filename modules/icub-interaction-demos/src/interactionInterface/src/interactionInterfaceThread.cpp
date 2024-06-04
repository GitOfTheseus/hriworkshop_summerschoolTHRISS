//
/*
  * Copyright (C)2017  Department of Robotics Brain and Cognitive Sciences - Istituto Italiano di Tecnologia
  * Author:Francesco Rea & Gonzalez Jonas
  * email: francesco.rea@iit.it
  * Permission is granted to copy, distribute, and/or modify this program
  * under the terms of the GNU General Public License, version 2 or any
  * later version published by the Free Software Foundation.
  *
  * A copy of the license can be found at
  * http://www.robotcub.org/icub/license/gpl.txt
  *
  * This program is distributed in the hope that it will be useful, but
  * WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
  * Public License for more details
*/

/**
 * @file interactionInterface.cpp
 * @brief Implementation of the interactionInterface thread (see interactionInterfaceThread.h).
 */

//

#include <iCub/interactionInterfaceThread.h>
#include <sys/stat.h>
#include <utility>
#include <signal.h>


using namespace std;


interactionInterfaceThread::interactionInterfaceThread() {
    robot = "icub";
    audioPlayer = "cvlc";
}

bool interactionInterfaceThread::threadInit() {


    inputTextName = name +"/text:i";
    outputImageName =  name +"/imageText:o";


    if(!inputTextPort.open(inputTextName.c_str())){
        cout <<": unable to open port /text:i"  << endl;
        return false;  // unable to open; let RFModule know so that it won't run
    }

    if(!outputImageTextPort.open(outputImageName.c_str())){
        cout <<": unable to open port /imageText:i"  << endl;
        return false;  // unable to open; let RFModule know so that it won't run
    }


    outputImageIpl = cvCreateImage(cvSize(width, height), IPL_DEPTH_8U, 3);

    yInfo("Successful initialization of the thread");

    return true;
}

interactionInterfaceThread::interactionInterfaceThread(string _robot, yarp::os::ResourceFinder rf) {
    robot = std::move(_robot);
    audioPlayer = rf.check("audioPlayer",
                           yarp::os::Value("cvlc"),
                           "Audio player (string)").asString();
}


interactionInterfaceThread::interactionInterfaceThread(string scriptName, string _robot, yarp::os::ResourceFinder rf) {
    m_scriptName = std::move(scriptName);
    robot = std::move(_robot);
    audioPlayer = rf.check("audioPlayer",
                           yarp::os::Value("cvlc"),
                           "Audio player (string)").asString();
}

void interactionInterfaceThread::onStop() {
    this->threadRelease();
    Thread::onStop();
}

void interactionInterfaceThread::threadRelease() {

    inputTextPort.interrupt();
    outputImageTextPort.interrupt();

    inputTextPort.close();
    outputImageTextPort.close();
    Thread::threadRelease();
}

void interactionInterfaceThread::run() {
	
	// @Luca removing this part since it is not used and deprecated in YARP 3.9
    // while (!isStopping()) {

    //     const yarp::os::Bottle *textBottle = inputTextPort.read(false);
    //     if (textBottle != nullptr) {
    //         string receivedText = textBottle->toString().c_str();

    //         cv::Mat imageWithTextMat = writeTextToImage(receivedText);
    //         IplImage imageWithTextIpl= cvIplImage(imageWithTextMat);
    //         cvCvtColor(&imageWithTextIpl, outputImageIpl, CV_RGB2BGR);


    //         if (outputImageTextPort.getOutputCount() > 0) {
    //             	yarp::sig::ImageOf<yarp::sig::PixelBgr> *processingRgbImage = &outputImageTextPort.prepare();
	// 	        processingRgbImage->resize(imageWithTextMat.cols, imageWithTextMat.rows);
	// 	        processingRgbImage->wrapIplImage(outputImageIpl);
	// 	        outputImageTextPort.write();
	//     }

    //     }
    // }

}


interactionInterfaceThread::~interactionInterfaceThread() = default;

void interactionInterfaceThread::setName(string str) {
    this->name= std::move(str);
    printf("name: %s \n", name.c_str());
}

string interactionInterfaceThread::getName(const char* p) {
    string str(name);
    str.append(p);
    return str;
}

vector<string> interactionInterfaceThread::exec(string cmdInput) {
    char buffer[128];
    //string result = "";
    vector<string> result;
    string finalCmd = m_scriptName +" "+cmdInput + " 2>&1";
    FILE* pipe = popen(finalCmd.c_str(), "r");
    if (!pipe) throw runtime_error("popen() failed!");
    try {
        while (!feof(pipe)) {
            if (fgets(buffer, 128, pipe) != NULL)
                result.push_back((string) buffer);
        }
    } catch (...) {
        pclose(pipe);
        throw;
    }
    pclose(pipe);
    return result;
}

vector<string> interactionInterfaceThread::exec(string cmdInput, yarp::os::Bottle params) {
    char buffer[128];
    //string result = "";
    vector<string> result;

    string finalCmd = m_scriptName +" "+cmdInput;   // March 2021, Dario Pasquali

    for (int i = 0; i < params.size(); i++) {
        finalCmd += " "+ params.get(i).toString();
    }

    yInfo("%s", finalCmd.c_str());

    finalCmd += " 2>&1";

    FILE* pipe = popen(finalCmd.c_str(), "r");
    if (!pipe) throw runtime_error("popen() failed!");
    try {
        while (!feof(pipe)) {
            if (fgets(buffer, 128, pipe) != NULL)
                result.push_back((string) buffer);
        }
    } catch (...) {
        pclose(pipe);
        throw;
    }
    pclose(pipe);
    return result;
}

vector<string> interactionInterfaceThread::formatTextToDisplay(string inputText, cv::Size textSize, cv::Mat displayImage) {
    std::vector<std::string> results;


    if (textSize.width > displayImage.cols - ( displayImage.cols * 0.65)) {
        std::istringstream iss(inputText);
        std::vector<std::string> listTokens((std::istream_iterator<std::string>(iss)), std::istream_iterator<std::string>());
        std::string temporaryString = listTokens[0]+" ";


        int i = 1;
        while (i < listTokens.size()) {

            string tmp = temporaryString + listTokens[i];
            cv::Size textSize = cv::getTextSize(tmp, cv::FONT_HERSHEY_COMPLEX, 1, 2 , 0);

            if (textSize.width >= displayImage.cols/2) {
                results.push_back(temporaryString);
                temporaryString = listTokens[i]+" ";

            } else {
                temporaryString.append(listTokens[i] +" ");
            }

            i++;

        }

        results.push_back(temporaryString);



    } else {
        results.push_back(inputText);
    }

    return results;
}


cv::Mat interactionInterfaceThread::writeTextToImage(string t_inputText){


    cv::Mat imageText(height, width, CV_8UC3, cv::Scalar(0));

    int baseLine = 0;
    cv::Size textSize = cv::getTextSize(t_inputText, cv::FONT_HERSHEY_COMPLEX, 2, 2 , &baseLine);
    std::vector<std::string> formatText = formatTextToDisplay(t_inputText, textSize, imageText);

    int offset_height = 0;
    for (auto tmp : formatText) {
        textSize = cv::getTextSize(tmp, cv::FONT_HERSHEY_COMPLEX, 2, 2 , &baseLine);

        const int xOriginText = (width/2  - textSize.width/2);
        const int yOriginText = 20 + textSize.height + offset_height;


        cv::Point origine(xOriginText, yOriginText);
        cv::putText(imageText, tmp, origine, cv::FONT_HERSHEY_COMPLEX, 2, CV_RGB(255, 255, 255), 2);
        offset_height += textSize.height + 30 ;


    }


    return imageText;
}

bool checkSuccessCommmand(FILE* pipe){
    char buffer[128];
    if (fgets(buffer, 128, pipe) != nullptr){
        const string returnMsg = (string) buffer;

        if(returnMsg.find("not found") !=  string::npos){
            return false;
        }
    }

    return true;
}



inline bool file_exist(const std::string& name) {
    struct stat buffer;
    return (stat (name.c_str(), &buffer) == 0);
}

bool interactionInterfaceThread::loadFile(std::string t_file) {
    if(file_exist(t_file)){

        m_scriptName = t_file;
        return true;
    }

    return false;
}


bool interactionInterfaceThread::playAudioFile(std::string t_nameAudioFile, int &PIPEPID) {

    string finalCmd = audioPlayer + " " + t_nameAudioFile + " 2>&1 &";
    //FILE* pipe = popen(finalCmd.c_str(), "r");
    int pipePid = -1;
    FILE* pipe = popen2(finalCmd.c_str(), "r",pipePid);
    if (!pipe){
        cout << "popen() failed!" << endl;
        PIPEPID = -1;
        return false;
    }
    yInfo("%s Pid: %d", finalCmd.c_str(),pipePid);
    filePidPairs[pipePid] = pipe;
    PIPEPID = pipePid;
    return checkSuccessCommmand(pipe);
}


FILE* interactionInterfaceThread::popen2(string command, string type, int & pid)
{
    pid_t child_pid;
    int fd[2];
    pipe(fd);

    if((child_pid = fork()) == -1)
    {
        perror("fork");
        exit(1);
    }

    /* child process */
    if (child_pid == 0)
    {
        if (type == "r")
        {
            close(fd[READ]);    //Close the READ end of the pipe since the child's fd is write-only
            dup2(fd[WRITE], 1); //Redirect stdout to pipe
        }
        else
        {
            close(fd[WRITE]);    //Close the WRITE end of the pipe since the child's fd is read-only
            dup2(fd[READ], 0);   //Redirect stdin to pipe
        }

        setpgid(child_pid, child_pid); //Needed so negative PIDs can kill children of /bin/sh
        execl("/bin/sh", "/bin/sh", "-c", command.c_str(), NULL);
        exit(0);
    }
    else
    {
        if (type == "r")
        {
            close(fd[WRITE]); //Close the WRITE end of the pipe since parent's fd is read-only
        }
        else
        {
            close(fd[READ]); //Close the READ end of the pipe since parent's fd is write-only
        }
    }

    pid = child_pid;

    if (type == "r")
    {
        return fdopen(fd[READ], "r");
    }

    return fdopen(fd[WRITE], "w");
}

int interactionInterfaceThread::pclose2(FILE * fp, pid_t pid)
{
    int stat;

    fclose(fp);
    while (waitpid(pid, &stat, 0) == -1)
    {
        if (errno != EINTR)
        {
            stat = -1;
            break;
        }
    }

    return stat;
}

bool interactionInterfaceThread::stopAllAudio() {

    map<int, FILE*>::iterator it;
    bool suc = true;
    while(filePidPairs.size())
    {
        it = filePidPairs.begin();
        suc = suc && stopAudio( it->first);
    }
    filePidPairs.clear();
    return suc;
}

bool interactionInterfaceThread::stopAudio(int pipePid) {

    map<int, FILE*>::iterator it;
    it=filePidPairs.find(pipePid);
    if (it != filePidPairs.end()){
        pclose2(filePidPairs.find(pipePid)->second, pipePid);
        kill((pipePid+1), SIGTERM);
        filePidPairs.erase(it);
        yInfo("stopped %d",pipePid);
        return true;
    }
    yInfo("not Found %d",pipePid);
    return false;
}


