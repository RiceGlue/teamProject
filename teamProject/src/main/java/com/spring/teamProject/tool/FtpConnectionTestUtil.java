package com.spring.teamProject.tool;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

import org.apache.commons.net.ftp.FTP;
import org.apache.commons.net.ftp.FTPClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class FtpConnectionTestUtil {

    private static final Logger logger = LoggerFactory.getLogger(FtpConnectionTestUtil.class);

    @Value("${ftp.server.host}")
    private String host;
    @Value("${ftp.server.port}")
    private int port;
    @Value("${ftp.server.username}")
    private String username;
    @Value("${ftp.server.password}")
    private String password;
    @Value("${ftp.server.directory}")
    private String baseDirectory;

    public boolean runFtpTest() {
        FTPClient ftpClient = new FTPClient();
        try {
            logger.info("--- FTP 연결 테스트 시작 ---");
            
            // 1. 서버 연결 및 로그인
            ftpClient.connect(host, port);
            boolean loginSuccess = ftpClient.login(username, password);
            if (!loginSuccess) {
                logger.error("FTP 로그인 실패! 아이디 또는 비밀번호를 확인하세요.");
                return false;
            }
            logger.info("1. FTP 로그인 성공.");

            // 2. 패시브 모드 설정
            ftpClient.enterLocalPassiveMode();
            logger.info("2. 패시브 모드 진입.");

            // 3. 파일 타입 설정
            ftpClient.setFileType(FTP.BINARY_FILE_TYPE);
            logger.info("3. 파일 타입을 바이너리로 설정.");

            // 4. 기본 디렉토리로 이동
            if (!ftpClient.changeWorkingDirectory(baseDirectory)) {
                int replyCode = ftpClient.getReplyCode();
                String replyString = ftpClient.getReplyString();
                logger.error("4. 기본 디렉토리 이동 실패: {}", baseDirectory);
                logger.error("   FTP 서버 응답 코드: {}", replyCode);
                logger.error("   FTP 서버 응답 메시지: {}", replyString);
                return false;
            }
            logger.info("4. 기본 디렉토리 이동 성공: {}", ftpClient.printWorkingDirectory());

            // 5. 새로운 테스트 폴더 생성
            String testDir = "test_folder_from_java";
            boolean dirCreated = ftpClient.makeDirectory(testDir);
            if (dirCreated) {
                logger.info("5. 테스트 폴더 생성 성공: {}", testDir);
            } else {
                logger.warn("5. 테스트 폴더가 이미 존재하거나 생성에 실패했습니다.");
            }

            // 6. 생성된 테스트 폴더로 이동
            if (!ftpClient.changeWorkingDirectory(testDir)) {
                logger.error("6. 테스트 폴더로 이동 실패: {}", testDir);
                return false;
            }
            logger.info("6. 테스트 폴더로 이동 성공: {}", ftpClient.printWorkingDirectory());

            // 7. 테스트 텍스트 파일 업로드
            String testFileName = "test_file.txt";
            String fileContent = "FTP upload test from Java application is successful!";
            InputStream inputStream = new ByteArrayInputStream(fileContent.getBytes(StandardCharsets.UTF_8));
            
            boolean fileUploaded = ftpClient.storeFile(testFileName, inputStream);
            inputStream.close();

            if (fileUploaded) {
                logger.info("7. 테스트 파일 업로드 성공: {}", testFileName);
            } else {
                logger.error("7. 테스트 파일 업로드 실패!");
                return false;
            }

            logger.info("--- ✅ FTP 연결 및 업로드 테스트 성공! ---");
            return true;

        } catch (Exception e) {
            logger.error("--- ❌ FTP 테스트 중 예외 발생 ---", e);
            return false;
        } finally {
            try {
                if (ftpClient.isConnected()) {
                    ftpClient.logout();
                    ftpClient.disconnect();
                }
            } catch (IOException ex) {
                logger.error("FTP 연결 종료 중 오류 발생", ex);
            }
        }
    }
}
