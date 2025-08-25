package com.spring.teamProject.service;

import java.io.File;
import java.io.IOException;

public interface FtpService {

    /**
     * 지정된 로컬 파일을 FTP 서버의 특정 하위 디렉토리로 업로드합니다.
     *
     * @param localFile        업로드할 로컬 파일 객체
     * @param subDirectory     저장할 하위 폴더 이름 (예: "profile")
     * @param remoteFileName   FTP 서버에 저장될 파일 이름
     * @return 업로드 성공 시 true, 실패 시 false
     */
    boolean uploadFile(File localFile, String subDirectory, String remoteFileName);

    /**
     * ✨ --- [신규] FTP 서버의 특정 하위 디렉토리에서 파일을 다운로드합니다. --- ✨
     * @param subDirectory     파일이 있는 하위 폴더 이름
     * @param fileName         다운로드할 파일 이름
     * @return 파일의 바이너리 데이터 (byte 배열)
     * @throws IOException 파일이 없거나 연결 실패 시 발생
     */
    byte[] downloadFile(String subDirectory, String fileName) throws IOException;
}
